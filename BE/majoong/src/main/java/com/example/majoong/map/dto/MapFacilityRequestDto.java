package com.example.majoong.map.dto;

import lombok.Builder;
import lombok.Data;
import lombok.Getter;

@Data
public class MapFacilityRequestDto {

    private Double centerLng;
    private Double centerLat;
    private Double radius;

    public MapFacilityRequestDto() {}
}
