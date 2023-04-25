package com.example.majoong.user.service;

import com.example.majoong.exception.DuplicateUserException;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.CreateUserDto;
import com.example.majoong.user.dto.KakaoLoginDto;
import com.example.majoong.user.dto.ResponseUserDto;
import com.example.majoong.user.dto.TokenDto;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class UserService {
    @Autowired
    private UserRepository userRepository;
    private final JwtTool jwtTool;

    public void createUser(CreateUserDto createUserDto) {

        String phoneNumber = createUserDto.getPhoneNumber();
        String nickname = createUserDto.getNickname();
        String profileImage = createUserDto.getProfileImage();
        String pinNumber = createUserDto.getPinNumber();
        String oauth = createUserDto.getOauth();


        User existingUser = userRepository.findByPhoneNumber(phoneNumber);
        if (existingUser != null) {
            throw new DuplicateUserException();
        }

        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setNickname(nickname);
        user.setProfileImage(profileImage);
        user.setPinNumber(pinNumber);
        user.setOauth(oauth);

        userRepository.save(user);
    }

    public User getUserByToken(String token){
        User user = userRepository.findByRefreshToken(token);
        return user;
    }

    public TokenDto generateUser(int id) {
        String accessToken = "Bearer " + jwtTool.createAccessToken(id);
        String refreshToken = "Bearer " + jwtTool.createRefreshToken(id);
        TokenDto user = new TokenDto(id,accessToken,refreshToken);
        return user;
    }

    public ResponseUserDto KakaoLogin(KakaoLoginDto info){
        User findUser = userRepository.findByOauth(info.getKakaoId());
        if (findUser == null){
            throw new NoUserException();
        }
        TokenDto token = generateUser(findUser.getId());
        ResponseUserDto user = new ResponseUserDto();
        user.setUserId(findUser.getId());
        user.setAccessToken(token.getAccessToken());
        user.setPhoneNumber(findUser.getPhoneNumber());
        user.setPinNumber(findUser.getPinNumber());
        return user;
    }

}
