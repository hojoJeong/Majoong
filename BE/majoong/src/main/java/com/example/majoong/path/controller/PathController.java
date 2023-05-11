package com.example.majoong.path.controller;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.path.dto.PathRequestDto;
import com.example.majoong.path.dto.PathResponseDto;
import com.example.majoong.path.dto.NodeDto;
import com.example.majoong.path.service.RecommendedPathService;
import com.example.majoong.path.service.ShortestPathService;
import com.example.majoong.response.ResponseData;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/map")
@Tag(name = "지도 경로 API", description = "최단 경로, 안전 경로, 도로 데이터 처리")
public class PathController {

    @Autowired
    private final RecommendedPathService recommendedPathService;
    private final ShortestPathService shortestPathService;

    @PostMapping("/path")
    @Operation(summary = "경로 추천 API", description = "최단 거리, 안전 거리 반환")
    public ResponseEntity getPath(@RequestBody PathRequestDto pathRequestDto) {
        double startLng = pathRequestDto.getStartLng();
        double startLat = pathRequestDto.getStartLat();
        double endLng = pathRequestDto.getEndLng();
        double endLat = pathRequestDto.getEndLat();

        ResponseData data = new ResponseData();
        data.setStatus(200);
        data.setMessage("경로 추천 성공");

        Map<String,Object> shortPath = shortestPathService.getShortestPath(startLng, startLat, endLng, endLat);
        if (shortPath.get("point") == null){
            data.setStatus(404);
            data.setMessage("최단거리 추천 오류");
        }

        Map<String, Object> recommendedPath = recommendedPathService.getRecommendedPath(startLng, startLat, endLng, endLat);
        if (recommendedPath == null) {
            data.setStatus(404);
            data.setMessage("안전경로 추천 오류");
        }

        Map<String,Object> result = new HashMap<>();
        result.put("recommendedPath", recommendedPath);
        result.put("shortestPath", shortPath);

        data.setData(result);
        return data.builder();
    }
}
