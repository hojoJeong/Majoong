package com.example.majoong.map.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@NoArgsConstructor
@Data
public class LocationRequestDto {
    int userId;
    List<Integer> guardians;
    boolean isRecommend;
    double startLng;
    double startLat;
    double endLng;
    double endLat;

}
