package com.example.majoong.user.dto;

import lombok.Data;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Data
public class CreateUserDto {

    private String phoneNumber;
    private String nickname;
    private String profileImage;
    private String pinNumber;

}
