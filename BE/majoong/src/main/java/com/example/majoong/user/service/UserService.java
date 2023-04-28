package com.example.majoong.user.service;

import com.example.majoong.exception.*;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class UserService {
    @Autowired
    private UserRepository userRepository;

    private final JwtTool jwtTool;

    public UserInformationDto getUser(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        User user = userRepository.findById(userId).get();
        if (user == null){
            throw new NoUserException();
        }
        UserInformationDto userInfo = new UserInformationDto();
        userInfo.setUserId(user.getId());
        userInfo.setPhoneNumber(user.getPhoneNumber());
        userInfo.setNickname(user.getNickname());
        userInfo.setProfileImage(user.getProfileImage());
        userInfo.setAlarmCount(user.getAlarmCount());

        return userInfo;
    }
    public void signupUser(CreateUserDto createUserDto) {

        String phoneNumber = createUserDto.getPhoneNumber();
        String nickname = createUserDto.getNickname();
        String profileImage = createUserDto.getProfileImage();
        String pinNumber = createUserDto.getPinNumber();
        String oauth = createUserDto.getOauth();


        User existingUser = userRepository.findByPhoneNumber(phoneNumber);
        if (existingUser != null) {
            throw new DuplicatePhoneNumberException();
        }

        User existingUser2 = userRepository.findByOauth(oauth);
        if (existingUser2 != null) {
            throw new DuplicateOauthException();
        }

        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setNickname(nickname);
        user.setProfileImage(profileImage);
        user.setPinNumber(pinNumber);
        user.setOauth(oauth);

        userRepository.save(user);
    }

    public TokenDto generateUser(int id) {
        String accessToken = jwtTool.createAccessToken(id);
        String refreshToken = jwtTool.createRefreshToken(id);
        TokenDto user = new TokenDto(id,accessToken,refreshToken);
        return user;
    }

    public ResponseUserDto Login(LoginDto info){
        User findUser = userRepository.findByOauth(info.getOauth());
        if (findUser == null){
            throw new NoUserException();
        }
        if (findUser.getState() == 0) {
            throw new DeletedUserException();
        }
        TokenDto token = generateUser(findUser.getId());
        ResponseUserDto user = new ResponseUserDto();
        user.setUserId(findUser.getId());
        user.setAccessToken(token.getAccessToken());
        user.setRefreshToken(token.getRefreshToken());
        user.setPhoneNumber(findUser.getPhoneNumber());
        user.setPinNumber(findUser.getPinNumber());
        return user;
    }

    public TokenDto reToken(ReTokenDto token){
        if(token.getRefreshToken() == null
                || !jwtTool.validateToken(token.getRefreshToken())) {
            throw new RefreshTokenException();
        }
        String newAccessToken = "Bearer " + jwtTool.createAccessToken(token.getUserId());
        TokenDto newToken = new TokenDto(token.getUserId(), newAccessToken, token.getRefreshToken());
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



}
