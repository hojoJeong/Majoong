package com.example.majoong.path.dto;

import lombok.*;


@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PathResponseDto {
    private PathInfoDto recommendedPath;
    private PathInfoDto shortestPath;

}
