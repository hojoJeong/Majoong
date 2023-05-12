package com.example.majoong.map.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.util.List;
import java.util.Map;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class SafeRoadMapDto {
    private Long safeRoadNumber;
    private List<SafeRoadPointDto> point;
    private String address;
}
