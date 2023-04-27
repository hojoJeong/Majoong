package com.example.majoong.map.dto;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CctvDto {
    private Long cctvId;
    private double longitude;
    private double latitude;
    private String address;
}
