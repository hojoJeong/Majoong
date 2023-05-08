package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class ResponseUserDto {

    private int userId;
    private String accessToken;
    private String refreshToken;
    private String phoneNumber;
    private String pinNumber;

}
