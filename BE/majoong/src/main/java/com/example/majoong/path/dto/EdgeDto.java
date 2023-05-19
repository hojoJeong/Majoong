package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.awt.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EdgeDto {
    private Long edgeId;
    private Long sourceId;
    private double sourceLng;
    private double sourceLat;
    private Long targetId;
    private double targetLng;
    private double targetLat;
    private int safety;
    private double distance;
    private double centerLng;
    private double centerLat;
}
