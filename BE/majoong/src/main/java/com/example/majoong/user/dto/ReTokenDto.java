package com.example.majoong.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class ReTokenDto {
    int id;
    String accessToken;
    String refreshToken;
}
