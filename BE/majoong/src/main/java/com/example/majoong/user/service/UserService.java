package com.example.majoong.user.service;

import com.example.majoong.exception.DuplicateUserException;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.CreateUserDto;
import com.example.majoong.user.dto.KakaoUserDto;
import com.example.majoong.user.repository.UserRepository;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public void createUser(CreateUserDto createUserDto) {

        String phoneNumber = createUserDto.getPhoneNumber();
        String nickname = createUserDto.getNickname();
        String profileImage = createUserDto.getProfileImage();
        String pinNumber = createUserDto.getPinNumber();

        User existingUser = userRepository.findByPhoneNumber(phoneNumber);
        if (existingUser != null) {
            throw new DuplicateUserException();
        }

        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setNickname(nickname);
        user.setProfileImage(profileImage);
        user.setPinNumber(pinNumber);

        userRepository.save(user);
    }

    public User getUserByToken(String token){
        User user = userRepository.findByRefreshToken(token);
        return user;
    }
    public KakaoUserDto kakaoOauth(String code) {
        String REST_API_KEY = "55f155e87d8c42c87ee9d43965bf4adf";
        OkHttpClient client = new OkHttpClient();

        RequestBody requestBody = null;
        Response response = null;
        String responseBody = "";

        String access_token = code;
        Request request = new Request.Builder()
                .url("https://kapi.kakao.com/v2/user/me")
                .header("Authorization", "Bearer " + access_token)
                .get()
                .build();

        Call call = client.newCall(request);
        try {
            response = call.execute();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        responseBody = "";
        if (response.isSuccessful()) {
            try {
                responseBody = response.body().string();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        KakaoUserDto kakaoUser = new Gson().fromJson(responseBody, KakaoUserDto.class);
        return kakaoUser;
    }

}
