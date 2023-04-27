package com.example.majoong.map.dto;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BellDto {
    private Long bellId;
    private double longitude;
    private double latitude;
    private String address;
}
