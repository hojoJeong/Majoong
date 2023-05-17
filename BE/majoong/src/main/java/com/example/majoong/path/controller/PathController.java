package com.example.majoong.path.controller;

import com.example.majoong.path.dto.*;
import com.example.majoong.path.service.RecommendedPathService;
import com.example.majoong.path.service.ShortestPathService;
import com.example.majoong.response.ResponseData;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
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
    public ResponseEntity getPath(@RequestBody PathRequestDto pathRequestDto) throws IOException {
        double startLng = pathRequestDto.getStartLng();
        double startLat = pathRequestDto.getStartLat();
        double endLng = pathRequestDto.getEndLng();
        double endLat = pathRequestDto.getEndLat();

        ResponseData data = new ResponseData();
        data.setStatus(200);
        data.setMessage("경로 추천 성공");

        // 30km 초과 예외처리
        double checkDistance = recommendedPathService.calcDistance(startLng, startLat, endLng, endLat);
        if (checkDistance >= 30000) {
            data.setStatus(406);
            data.setMessage("직선거리가 30km를 초과했습니다.");
            PathResponseDto path = new PathResponseDto();
            path.setRecommendedPath(null);
            path.setShortestPath(null);
            data.setData(path);

            return data.builder();
        }

        PathInfoDto shortPath = shortestPathService.getShortestPath(startLng, startLat, endLng, endLat);
        if (shortPath.getPoint()==null||shortPath==null){
            data.setStatus(404);
            data.setMessage("최단거리 추천 오류");
        }

        PathInfoDto recommendedPath = recommendedPathService.getRecommendedPath(startLng, startLat, endLng, endLat);
        if (recommendedPath == null) {
            data.setStatus(404);
            data.setMessage("안전경로 추천 오류");
        }

        PathResponseDto path = new PathResponseDto();
        path.setRecommendedPath(recommendedPath);
        path.setShortestPath(shortPath);
        data.setData(path);

        return data.builder();
    }

    @GetMapping("/path/safety")
    public void getPath() {

        recommendedPathService.setEdgeSafety();

        log.info("safety 값 설정 성공");
    }

    @PostMapping("/path/test")
    @Operation(summary = "경로 추천 API", description = "최단 거리, 안전 거리 반환")
    public ResponseEntity testPath(@RequestBody PathRequestDto pathRequestDto) throws IOException {
        double startLng = pathRequestDto.getStartLng();
        double startLat = pathRequestDto.getStartLat();
        double endLng = pathRequestDto.getEndLng();
        double endLat = pathRequestDto.getEndLat();

        ResponseData data = new ResponseData();
        data.setStatus(200);
        data.setMessage("경로 추천 성공");

        PathInfoDto recommendedPath = recommendedPathService.testRecommendedPath(startLng, startLat, endLng, endLat);
        if (recommendedPath == null) {
            data.setStatus(404);
            data.setMessage("안전경로 추천 오류");
        }

        //////
        NodeDto startNode = recommendedPathService.findNearestNode(startLng, startLat);
        NodeDto endNode = recommendedPathService.findNearestNode(endLng, endLat);
        GraphDto astarGraph = recommendedPathService.createAstarGraph(startNode, endNode);
        /////////////

        PathResponseDto path = new PathResponseDto();
        path.setRecommendedPath(recommendedPath);
        path.setShortestPath(null);

        data.setData(astarGraph);

        return data.builder();
    }

}
