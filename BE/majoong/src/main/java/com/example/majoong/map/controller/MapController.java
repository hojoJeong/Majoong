package com.example.majoong.map.controller;

import com.example.majoong.map.dto.LocationRequestDto;
import com.example.majoong.map.dto.MapFacilityRequestDto;
import com.example.majoong.map.dto.MapFacilityResponseDto;
import com.example.majoong.map.service.MapDataService;
import com.example.majoong.map.service.MapFacilityService;
import com.example.majoong.map.service.MapService;
import com.example.majoong.response.ResponseData;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/map")
public class MapController {
    @Autowired
    private final MapFacilityService mapFacilityService;
    private final MapDataService mapDataService;

    private final MapService mapService;

    @GetMapping("/facility")
    public ResponseEntity getFacility(@RequestBody MapFacilityRequestDto position) {
        MapFacilityResponseDto facilities = mapFacilityService.getMapFacilities(position);

        ResponseData data = new ResponseData();
        data.setStatus(200);
        data.setData(facilities);
        data.setMessage("시설물 조회 성공");
        return data.builder();
    }

    @GetMapping("/save/csv")
    public String saveCsv() {
        mapDataService.saveCsvToMysql();                      // csv파일을 MySQL에 저장

        return "MySQL에 저장 성공";
    }

    @GetMapping("/save/redis")
    public String saveRedis() {
        mapDataService.saveMysqlToRedisGeospatial();               // DB의 데이터 Redis로 동기화

        return "Reids에 저장 성공";
    }

    @PostMapping("/share")
    public ResponseEntity startMoving(LocationRequestDto locationRequest){
        mapService.startMoving(locationRequest);
        ResponseData data = new ResponseData();
        data.setMessage("위치 공유 시작");
        return data.builder();
    }

}