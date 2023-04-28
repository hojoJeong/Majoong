package com.example.majoong.map.dto;

import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class PoliceDto extends FacilityDto {
    private Long policeId;
}
