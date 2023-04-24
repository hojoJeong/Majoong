package com.example.majoong.user.service;

import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.CreateUserDto;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public User createUser(CreateUserDto createUserDto) {

        String phoneNumber = createUserDto.getPhoneNumber();
        String nickname = createUserDto.getNickname();
        String profileImage = createUserDto.getProfileImage();
        String pinNumber = createUserDto.getPinNumber();

        User user = new User();
        user.setPhoneNumber(phoneNumber);
        user.setNickname(nickname);
        user.setProfileImage(profileImage);
        user.setPinNumber(pinNumber);

        // User 저장
        User savedUser = userRepository.save(user);

        return savedUser;
    }
}
