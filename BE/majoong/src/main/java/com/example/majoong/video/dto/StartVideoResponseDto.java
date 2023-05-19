package com.example.majoong.video.dto;

import lombok.Data;

@Data
public class StartVideoResponseDto {
    String sessionId;
    String connectionId;
    String connectionToken;

}
