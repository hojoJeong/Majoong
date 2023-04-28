package com.example.majoong.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class TokenDto {

    int userId;
    String accessToken;
    String refreshToken;

}
