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
    private Long targetId;
    private int distanceVal;
    private int safeVal;
    private double centerLng;
    private double centerLat;

    /**
     * 실제 postGIS에 어떻게 들어가는지에 따라서 수정하기
     */
//    private Point source;
//    private Point target;
//    private String address;

}
