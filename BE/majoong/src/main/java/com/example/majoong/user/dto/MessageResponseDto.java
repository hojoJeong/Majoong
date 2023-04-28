package com.example.majoong.user.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MessageResponseDto {

    private String requestId;
    private LocalDateTime requestTime;
    private String statusCode;
    private String statusName;
}
