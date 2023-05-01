package com.example.majoong.map.controller;

import com.example.majoong.map.dto.MapFacilityRequestDto;
import com.example.majoong.map.dto.MapFacilityResponseDto;
import com.example.majoong.map.service.MapDataService;
import com.example.majoong.map.service.MapFacilityService;
import com.example.majoong.response.ResponseData;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/map")
@Tag(name = "지도 시설물 API", description = "시설물 조회, DB 저장, Redis 저장")
public class MapController {
    @Autowired
    private final MapFacilityService mapFacilityService;
    private final MapDataService mapDataService;

    @GetMapping("/facility")
    @Operation(summary = "시설물 조회 API", description = "cctv, 가로등, 비상벨, 경찰서, 편의점, 안심귀갓길, 위험지역, 리뷰")
    public ResponseEntity getFacility(@RequestBody MapFacilityRequestDto position) {
        MapFacilityResponseDto facilities = mapFacilityService.getMapFacilities(position);

        ResponseData data = new ResponseData();
        data.setStatus(200);
        data.setData(facilities);
        data.setMessage("시설물 조회 성공");
        return data.builder();
    }

    @GetMapping("/save/csv")
    @Operation(summary = "CSV파일 데이터 DB로 저장", description = "데이터 저장용")
    public String saveCsv() {
        mapDataService.saveCsvToMysql();                      // csv파일을 MySQL에 저장

        return "MySQL에 저장 성공";
    }

    @GetMapping("/save/redis")
    @Operation(summary = "DB 데이터 Redis로 저장", description = "데이터 동기화용")
    public String saveRedis() {
        mapDataService.saveMysqlToRedisGeospatial();               // DB의 데이터 Redis로 동기화

        return "Reids에 저장 성공";
    }
}