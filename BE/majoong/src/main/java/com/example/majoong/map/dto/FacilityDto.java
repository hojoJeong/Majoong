package com.example.majoong.map.dto;

import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class FacilityDto {
    private double longitude;
    private double latitude;
    private String address;
}
