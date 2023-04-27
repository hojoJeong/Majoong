package com.example.majoong.map.dto;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreDto {
    private Long storeId;
    private double longitude;
    private double latitude;
    private String address;
}
