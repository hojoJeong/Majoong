package com.example.majoong.user.dto;

import lombok.Data;


@Data
public class MessageResponseDto {

    private String requestId;
    private String statusCode;
    private String statusName;
}
