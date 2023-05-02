package com.example.majoong.map.dto;

import lombok.Data;

import java.util.List;

@Data
public class LocationRequestDto {
    int userId;
    List<Integer> guardians;
    boolean isRecommended;
    double startLng;
    double startLat;
    double endLng;
    double endLat;

}
