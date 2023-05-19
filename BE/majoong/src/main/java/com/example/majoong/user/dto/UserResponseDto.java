package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class UserResponseDto {

    private int userId;
    private String accessToken;
    private String refreshToken;
    private String phoneNumber;
    private String pinNumber;

}
