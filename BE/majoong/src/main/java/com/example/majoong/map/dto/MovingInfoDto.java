package com.example.majoong.map.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.Map;


@AllArgsConstructor
@RequiredArgsConstructor
@Data
public class MovingInfoDto {

    double startLng;
    double startLat;
    double endLng;
    double endLat;
    Boolean isRecommend;

    List<Integer> guardians;

    List<Map<String,Object>> path;
}
