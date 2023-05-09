package com.example.majoong.path.dto;

import java.util.List;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PathResponseDto {
//{
//    "recommendedPath": [
//        {
//            "startPoint": {"lat": 37.7765804, "lng": -122.4245725},
//            "endPoint": {"lat": 37.7758652, "lng": -122.4234435},
//        },
//        {
//            "startPoint": {"lat": 37.7758652, "lng": -122.4234435},
//            "endPoint": {"lat": 37.7753915, "lng": -122.4227075},
//        },
//    ],
//    "shortestPath": [
//        {
//            "startPoint": {"lat": 37.7765804, "lng": -122.4245725},
//            "endPoint": {"lat": 37.7758652, "lng": -122.4234435},
//        },
//        {
//            "startPoint": {"lat": 37.7758652, "lng": -122.4234435},
//            "endPoint": {"lat": 37.7753915, "lng": -122.4227075},
//        },
//    ]
//}

//    private List<PathDto> recommendedPath;
//    private List<PathDto> shortestPath;

    private List<NodeDto> recommendedPath;
    private List<NodeDto> shortestPath;


}