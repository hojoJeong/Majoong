package com.example.majoong.map.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;


@AllArgsConstructor
@RequiredArgsConstructor
@Data
public class MovingInfoDto {

    double startLng;
    double startLat;
    double endLng;
    double endLat;
    boolean isRecommend;
}
