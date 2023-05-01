package com.example.majoong.map.dto;

import lombok.Data;

import java.util.List;

@Data
public class MapFacilityResponseDto {

    private List<PoliceDto> police;
    private List<StoreDto> store;
    private List<BellDto> bell;
    private List<CctvDto> cctv;
}
