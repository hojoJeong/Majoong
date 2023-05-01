package com.example.majoong.user.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class UserProfileRequestrDto {

    private String nickname;
    private String phoneNumber;

}
