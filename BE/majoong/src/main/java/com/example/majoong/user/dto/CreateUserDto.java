package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class CreateUserDto {

    private String phoneNumber;
    private String nickname;
    private String profileImage;
    private String pinNumber;

}
