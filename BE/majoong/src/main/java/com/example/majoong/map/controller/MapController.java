package com.example.majoong.map.controller;

import com.example.majoong.map.domain.Police;
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

    @GetMapping("/csv/save")
    public String saveCsv() {
        saveCsvToMysql();

        return "저장 성공";
    }

    public void saveCsvToMysql() {

        List<Police> policeList = loadPoliceList();
        mapRepositoryService.saveAll(policeList);
    }

    private List<Police> loadPoliceList() {
        return CsvUtils.convertToPoliceDtoList()
                .stream().map(policeDto ->
                        Police.builder()
                                .policeId(policeDto.getPoliceId())
                                .longitude(policeDto.getLongitude())
                                .latitude(policeDto.getLatitude())
                                .address(policeDto.getAddress())
                                .build())
                .collect(Collectors.toList());
    }
}

