package com.example.majoong.map.dto;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PoliceDto {
    private Long policeId;
    private float longitude;
    private float latitude;
    private String address;
}
