package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EdgePositionDto {
    private Long edgeId;
    private double centerLng;
    private double centerLat;
    private double distance;
}
