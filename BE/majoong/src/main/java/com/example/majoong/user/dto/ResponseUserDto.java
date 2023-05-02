package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class ResponseUserDto {

    private int userId;
    private String accessToken;
    private String refreshToken;
    private String phoneNumber;
    private String pinNumber;

    public String getPhoneNumber() {
        if (phoneNumber == null || phoneNumber.length() != 11) {
            return phoneNumber;
        }
        return phoneNumber.substring(0, 3) + "-" + phoneNumber.substring(3, 7) + "-" + phoneNumber.substring(7);
    }
}
