package com.example.majoong.map.dto;

import com.example.majoong.path.dto.PathInfoDto;
import lombok.Data;


@Data
public class LocationShareResponseDto {

    private String nickname;
    private String phoneNumber;
    private PathInfoDto path;
}
