package com.example.majoong.map.service;

import com.example.majoong.map.domain.Bell;
import com.example.majoong.map.domain.Cctv;
import com.example.majoong.map.domain.Police;
import com.example.majoong.map.domain.Store;
import com.example.majoong.map.dto.*;
import com.example.majoong.map.util.CsvUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;


import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapFacilityService {

    private final RedisOperations<String, String> redisOperations;

    public MapFacilityResponseDto getMapFacilities(MapFacilityRequestDto position) {
        double centerLng = position.getCenterLng();
        double centerLat = position.getCenterLat();
        double radius = position.getRadius();

        MapFacilityResponseDto facilities = new MapFacilityResponseDto();

        facilities.setPolice(getFacilityDtos("police", centerLng, centerLat, radius, PoliceDto.class));
        facilities.setStore(getFacilityDtos("store", centerLng, centerLat, radius, StoreDto.class));
        facilities.setBell(getFacilityDtos("bell", centerLng, centerLat, radius, BellDto.class));

        System.out.println(facilities.getBell().get(0).getAddress());
        return facilities;
    }

    private <T extends FacilityDto> List<T> getFacilityDtos(String key, double centerLng, double centerLat, double radius, Class<T> dtoClass) {
        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo()
                .radius(key, new Circle(new Point(centerLng, centerLat), new Distance(radius, RedisGeoCommands.DistanceUnit.METERS)), args);

        List<T> dtos = new ArrayList<>();
        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            T dto;
            try {
                dto = dtoClass.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | NoSuchMethodException | InvocationTargetException e) {
                throw new RuntimeException("dto 생성 실패", e);
            }

            dto.setLatitude(geoResult.getContent().getPoint().getY());
            dto.setLongitude(geoResult.getContent().getPoint().getX());
            dto.setAddress(geoResult.getContent().getName());
            dtos.add(dto);
        }
        return dtos;
    }

//    // GeoOperations 인터페이스를 사용합니다.
//    GeoOperations<String, String> geoOps = redisTemplate.opsForGeo();
//
//    // GeoRadius 명령어를 실행합니다.
//    String key = "myLocation";
//    Circle within = new Circle(new Point(longitude, latitude), new Distance(radius, Metrics.MILES));
//    GeoRadiusCommandArgs args = GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeHash().sortAscending();
//    GeoResults<GeoLocation<String>> results = geoOps.radius(key, within, args);
//
//    // 결과를 출력합니다.
//    for (GeoResult<GeoLocation<String>> result : results) {
//        GeoLocation<String> location = result.getContent();
//        double distance = result.getDistance().getValue();
//        Point coordinates = location.getPoint();
//        String member = location.getName();
//        String hash = location.getHash().toString();
//        System.out.println(member + " is " + distance + " miles away at " + coordinates + " (hash: " + hash + ")");
//    }



}
