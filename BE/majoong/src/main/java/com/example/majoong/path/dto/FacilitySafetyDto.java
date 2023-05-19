package com.example.majoong.path.dto;

import com.example.majoong.map.dto.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FacilitySafetyDto {

    private List<PoliceDto> police;
    private List<StoreDto> store;
    private List<BellDto> bell;
    private List<CctvDto> cctv;
    private List<LampDto> lamp;
    private List<SafeRoadMapDto> safeRoad;
}
