package com.example.majoong.video.dto;

import lombok.Data;

@Data
public class GetRecordingsResponseDto {
    String recordingId;
    String thumbnailImageUrl;
    String recordingUrl;
    String createdAt;
    long duration;
}
