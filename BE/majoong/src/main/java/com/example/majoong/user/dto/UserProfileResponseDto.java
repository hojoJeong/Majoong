package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class UserProfileResponseDto {

    private String nickname;
    private String phoneNumber;
    private String profileImage;

    public String getPhoneNumber() {
        if (phoneNumber == null || phoneNumber.length() != 11) {
            return phoneNumber;
        }
        return phoneNumber.substring(0, 3) + "-" + phoneNumber.substring(3, 7) + "-" + phoneNumber.substring(7);
    }

}
