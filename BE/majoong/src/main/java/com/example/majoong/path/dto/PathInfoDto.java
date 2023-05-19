package com.example.majoong.path.dto;

import com.example.majoong.map.dto.LocationDto;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
public class PathInfoDto {
    private int distance;
    private int time;
    private List<LocationDto> point;


}
