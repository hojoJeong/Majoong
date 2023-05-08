package com.example.majoong.user.dto;

import lombok.Data;

@Data
public class UserInformationDto {

    private int userId;
    private String phoneNumber;
    private String nickname;
    private String profileImage;
    private int alarmCount;


}


