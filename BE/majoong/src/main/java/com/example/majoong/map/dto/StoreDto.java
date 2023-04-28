package com.example.majoong.map.dto;

import lombok.*;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class StoreDto extends FacilityDto{
    private Long storeId;
}
