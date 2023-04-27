package com.example.majoong.map.controller;

import com.example.majoong.map.domain.Bell;
import com.example.majoong.map.domain.Cctv;
import com.example.majoong.map.domain.Police;
import com.example.majoong.map.domain.Store;
import com.example.majoong.map.dto.PoliceDto;
import com.example.majoong.map.dto.StoreDto;
import com.example.majoong.map.repository.BellRepository;
import com.example.majoong.map.repository.CctvRepository;
import com.example.majoong.map.repository.PoliceRepository;
import com.example.majoong.map.repository.StoreRepository;
import com.example.majoong.map.service.MapRedisService;
import com.example.majoong.map.service.MapRepositoryService;
import com.example.majoong.map.util.CsvUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/map")
public class MapController {
    private final MapRepositoryService mapRepositoryService;
    private final MapRedisService mapRedisService;
    private final PoliceRepository policeRepository;
    private final StoreRepository storeRepository;
    private final CctvRepository cctvRepository;
    private final BellRepository bellRepository;

    @GetMapping("/save/csv")
    public String saveCsv() {
        mapRepositoryService.saveCsvToMysql();                      // csv파일을 MySQL에 저장

        return "MySQL에 저장 성공";
    }

    @GetMapping("/save/redis")
    public String saveRedis() {
        mapRedisService.saveMysqlToRedisGeospatial();               // DB의 데이터 Redis로 동기화

        return "Reids에 저장 성공";
    }
}