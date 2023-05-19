package com.example.majoong.path.controller;

import com.example.majoong.exception.ExceedDistance;
import com.example.majoong.exception.SameNodeException;
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

        // 시작점, 도착점과 가장 가까운 노드 탐색
        NodeDto startNode = recommendedPathService.findNearestNode(startLng, startLat);
        NodeDto endNode = recommendedPathService.findNearestNode(endLng, endLat);

        // 시작점과 도착점이 같을 경우 예외 처리
        if (startNode.getNodeId().equals(endNode.getNodeId())) {
            throw new SameNodeException();
        }

        // 30km 초과 예외처리
        double checkDistance = recommendedPathService.calcDistance(startLng, startLat, endLng, endLat);
        if (checkDistance >= 30000) {
            throw new ExceedDistance();
        }

        PathInfoDto shortPath = shortestPathService.getShortestPath(startNode.getLng(), startNode.getLat(), endNode.getLng(), endNode.getLat());
        if (shortPath.getPoint()==null||shortPath==null){
            data.setStatus(404);
            data.setMessage("최단거리 추천 오류");
        }

        PathInfoDto recommendedPath = recommendedPathService.getRecommendedPath(startNode, endNode);
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

        // 도로 데이터의 edge 테이블에 safety 값 설정
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

        // 그래프 생성 테스트용
        NodeDto startNode = recommendedPathService.findNearestNode(startLng, startLat);
        NodeDto endNode = recommendedPathService.findNearestNode(endLng, endLat);
        GraphDto astarGraph = recommendedPathService.createAstarGraph(startNode, endNode);

        PathResponseDto path = new PathResponseDto();
        path.setRecommendedPath(recommendedPath);
        path.setShortestPath(null);

        data.setData(astarGraph);

        return data.builder();
    }
}
