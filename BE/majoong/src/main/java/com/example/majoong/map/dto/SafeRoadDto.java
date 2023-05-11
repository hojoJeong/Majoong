package com.example.majoong.map.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class SafeRoadDto extends FacilityDto{
    private Long safeRoadId;
    private Long safeRoadNumber;
}
