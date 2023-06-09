package com.example.majoong.user.service;

import com.example.majoong.exception.*;
import com.example.majoong.tools.S3Upload;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Nullable;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Optional;


@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    @Autowired
    private UserRepository userRepository;

    private final RedisTemplate redisTemplate;

    private final JwtTool jwtTool;
    private final S3Upload s3Upload;

    private final AmqpAdmin amqpAdmin;


    public UserInformationDto getUser(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        User user = userRepository.findById(userId).get();
        if (user == null) {
            throw new NoUserException();
        }
        UserInformationDto userInfo = new UserInformationDto();
        userInfo.setUserId(user.getId());
        userInfo.setPhoneNumber(user.getPhoneNumber());
        userInfo.setNickname(user.getNickname());
        userInfo.setProfileImage(user.getProfileImage());

        int count = redisTemplate.keys("notification:" + user.getId() + "_" + "*").size();
        userInfo.setAlarmCount(count);

        return userInfo;
    }
    public void signupUser(CreateUserDto createUserDto) {

        String phoneNumber = createUserDto.getPhoneNumber();
        String nickname = createUserDto.getNickname();
        String profileImage = createUserDto.getProfileImage();
        String pinNumber = createUserDto.getPinNumber();
        String socialPK = createUserDto.getSocialPK();


        User existingUser = userRepository.findByPhoneNumber(phoneNumber);
        if (existingUser != null) {
            throw new DuplicatePhoneNumberException();
        }

        User existingUser2 = userRepository.findBySocialPK(socialPK);
        if (existingUser2 != null) {
            throw new DuplicateSocialPKException();
        }

        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setNickname(nickname);
        user.setProfileImage(profileImage);
        user.setPinNumber(pinNumber);
        user.setSocialPK(socialPK);

        userRepository.save(user);

        initQueue(user.getId());
    }

    public TokenDto generateUser(int id) {
        String accessToken = jwtTool.createAccessToken(id);
        String refreshToken = jwtTool.createRefreshToken(id);
        TokenDto user = new TokenDto(id, accessToken, refreshToken);
        return user;
    }

    public UserResponseDto login(String socialPK,String fcmToken) {
        User findUser = userRepository.findBySocialPK(socialPK);
        if (findUser == null) {
            throw new NoUserException();
        }
        if (findUser.getState() == 0) {
            throw new DeletedUserException();
        }
        if (fcmToken!=null){
            findUser.setFcmToken(fcmToken);
            userRepository.save(findUser);
        }
        TokenDto token = generateUser(findUser.getId());
        UserResponseDto user = new UserResponseDto();
        user.setUserId(findUser.getId());
        user.setAccessToken(token.getAccessToken());
        user.setRefreshToken(token.getRefreshToken());
        user.setPhoneNumber(findUser.getPhoneNumber());
        user.setPinNumber(findUser.getPinNumber());
        return user;
    }

    public UserResponseDto autoLogin(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        return login(user.getSocialPK(), null);
    }

    public TokenDto reToken(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        if (token == null
                || !jwtTool.validateToken(token)) {
            throw new RefreshTokenException();
        }
        int userId = jwtTool.getUserIdFromToken(token);

        String newAccessToken = jwtTool.createAccessToken(userId);
        TokenDto newToken = new TokenDto(userId, newAccessToken, token);
        return newToken;
    }

    public String withdrawal(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> user = userRepository.findById(userId);
        if (user == null) {
            throw new NoUserException();
        }

        user.get().setState(0);
        userRepository.save(user.get());

        return "회원탈퇴 성공";
    }

    void initQueue(int id) {
        String queueName = "location.queue." + id;
        String exchangeName = "location.exchange";

        Queue queue = QueueBuilder.durable(queueName)
                .ttl(1000)
                .build();        amqpAdmin.declareQueue(queue);

        TopicExchange exchange = new TopicExchange(exchangeName);
        amqpAdmin.declareExchange(exchange);

        Binding binding = BindingBuilder.bind(queue)
                .to(exchange)
                .with(String.valueOf(id));
        amqpAdmin.declareBinding(binding);
    }

    public pinNumberDto changePin(HttpServletRequest request, String pinNumber){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        Optional<User> user = userRepository.findById(userId);
        if (user == null) {
            throw new NoUserException();
        }

        user.get().setPinNumber(pinNumber);
        userRepository.save(user.get());

        pinNumberDto pin = new pinNumberDto();
        pin.setPinNumber(user.get().getPinNumber());

        return pin;
    }
    public UserProfileResponseDto changeProfile(HttpServletRequest request, UserProfileRequestrDto userProfileRequestrDto, @Nullable MultipartFile profileImage) throws IOException {
        //토큰으로 유저 식별
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> user = userRepository.findById(userId);
        if (user == null) {
            throw new NoUserException();
        }

        // phoneNumber 중복확인
//        User existingUser = userRepository.findByPhoneNumber(userProfileRequestrDto.getPhoneNumber());
//        if (existingUser != null && user.get().getPhoneNumber() != userProfileRequestrDto.getPhoneNumber()) {
//            throw new DuplicatePhoneNumberException();
//        }
        user.get().setPhoneNumber(userProfileRequestrDto.getPhoneNumber());
        user.get().setNickname(userProfileRequestrDto.getNickname());

        if (profileImage!=null) {
            String fileType = "profile";
            String profileImageUrl = s3Upload.uploadFile(userId, fileType, profileImage);
            user.get().setProfileImage(profileImageUrl);
        }

        userRepository.save(user.get());

        UserProfileResponseDto userProfileResponseDto = new UserProfileResponseDto();
        userProfileResponseDto.setPhoneNumber(user.get().getPhoneNumber());
        userProfileResponseDto.setNickname(user.get().getNickname());
        userProfileResponseDto.setProfileImage(user.get().getProfileImage());

        return userProfileResponseDto;
    }

    public SimpleUserResponseDto searchPhoneNumber(String phoneNumber){
        User userInfo = userRepository.findByPhoneNumber(phoneNumber);
        if (userInfo == null ){
            throw new NoUserException();
        }
        SimpleUserResponseDto user = new SimpleUserResponseDto();

        user.setUserId(userInfo.getId());
        user.setPhoneNumber(userInfo.getPhoneNumber());
        user.setNickname(userInfo.getNickname());
        user.setProfileImage(userInfo.getProfileImage());
        return user;
    }

    public pushAlarmDto setPushAlarm(HttpServletRequest request, boolean push){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        user.setPushAlarm(push);
        pushAlarmDto pushDto = new pushAlarmDto();
        pushDto.setPushAlarm(user.isPushAlarm());
        return pushDto;
    }

    public pushAlarmDto getPushAlarm(HttpServletRequest request){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        pushAlarmDto pushDto = new pushAlarmDto();
        pushDto.setPushAlarm(user.isPushAlarm());
        return pushDto;
    }
}
