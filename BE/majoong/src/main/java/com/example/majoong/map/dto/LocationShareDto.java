package com.example.majoong.map.dto;

import com.example.majoong.path.dto.PathInfoDto;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@NoArgsConstructor
@Data
public class LocationShareDto {

    private int userId;
    private List<Integer> guardians;
    private PathInfoDto path;

}
