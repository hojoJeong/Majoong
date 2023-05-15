package com.example.majoong.map.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class RoadDto {

    int id;
    int roadId;
    double lng;
    double lat;
}
