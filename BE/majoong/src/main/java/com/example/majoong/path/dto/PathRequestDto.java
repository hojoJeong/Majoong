package com.example.majoong.path.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "경로 추천 요청 DTO")
public class PathRequestDto {

//    {
//        startLng: Double,
//        startLat: Double,
//        endLng: Double,
//        endLat: Double
//    }

    @Schema(description = "출발점 경도 Longitude X", example = "127.0039")
    private Double startLng;
    @Schema(description = "출발점 위도 Latitude Y", example = "37.5664")
    private Double startLat;
    @Schema(description = "도착점 경도 Longitude X", example = "127.0051")
    private Double endLng;
    @Schema(description = "도착점 위도 Latitude Y", example = "37.5675")
    private Double endLat;
}
