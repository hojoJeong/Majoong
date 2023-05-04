package com.example.majoong.map.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;

@Data
@Schema(description = "시설물 조회 요청 DTO")
public class MapFacilityRequestDto {

    @Schema(description = "현재위치 경도 Longitude", example = "127.0039")
    private Double centerLng;

    @Schema(description = "현재위치 위도 Latitude", example = "37.5664")
    private Double centerLat;

    @Schema(description = "검색 반경 (m)", example = "100")
    private Double radius;

    public MapFacilityRequestDto() {}
}
