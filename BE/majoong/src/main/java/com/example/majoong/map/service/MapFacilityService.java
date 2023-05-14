package com.example.majoong.map.service;

import com.example.majoong.map.domain.SafeRoad;
import com.example.majoong.map.dto.*;
import com.example.majoong.map.repository.SafeRoadRepository;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapFacilityService {

    private final Gson gson;

    private final RedisOperations<String, String> redisOperations;
    private final SafeRoadRepository safeRoadRepository;

    public MapFacilityResponseDto getMapFacilities(MapFacilityRequestDto position) {
        double centerLng = position.getCenterLng();
        double centerLat = position.getCenterLat();
        double radius = position.getRadius();

        MapFacilityResponseDto facilities = new MapFacilityResponseDto();

        facilities.setPolice(getFacilityDtos("police", centerLng, centerLat, radius, PoliceDto.class));
        facilities.setStore(getFacilityDtos("store", centerLng, centerLat, radius, StoreDto.class));
        facilities.setBell(getFacilityDtos("bell", centerLng, centerLat, radius, BellDto.class));
        facilities.setCctv(getFacilityDtos("cctv", centerLng, centerLat, radius, CctvDto.class));
        facilities.setLamp(getFacilityDtos("lamp", centerLng, centerLat, radius, LampDto.class));

        facilities.setReview(getFacilityDtos("review", centerLng, centerLat, radius, ReviewDto.class));

        facilities.setSafeRoad(getSafeRoadDtos("saferoad", centerLng, centerLat, radius));
        facilities.setRiskRoad(getRiskRoad("risk_road", centerLng, centerLat, radius));
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

            String[] member = geoResult.getContent().getName().split("_");
            String id = member[0];
            String address = member[1];

            if (dto instanceof PoliceDto) ((PoliceDto) dto).setPoliceId(Long.parseLong(id));
            else if (dto instanceof StoreDto) ((StoreDto) dto).setStoreId(Long.parseLong(id));
            else if (dto instanceof CctvDto) ((CctvDto) dto).setCctvId(Long.parseLong(id));
            else if (dto instanceof BellDto) ((BellDto) dto).setBellId(Long.parseLong(id));
            else if (dto instanceof LampDto) ((LampDto) dto).setLampId(Long.parseLong(id));
            else if (dto instanceof ReviewDto) {
                ((ReviewDto) dto).setReviewId(Long.parseLong(id));
                ((ReviewDto) dto).setScore(Integer.parseInt(member[2]));
            }

            dto.setLat(geoResult.getContent().getPoint().getY());
            dto.setLng(geoResult.getContent().getPoint().getX());
            dto.setAddress(address);
            dtos.add(dto);
        }
        return dtos;
    }

    public List<SafeRoadMapDto> getSafeRoadDtos(String key, double centerLng, double centerLat, double radius) {
        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo()
                .radius(key, new Circle(new Point(centerLng, centerLat), new Distance(radius, RedisGeoCommands.DistanceUnit.METERS)), args);

        List<Long> safeRoadNumberList = new ArrayList<>();
        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            String[] member = geoResult.getContent().getName().split("_");
            Long safeRoadNumber = Long.parseLong(member[2]);

            if (!safeRoadNumberList.contains(safeRoadNumber)) {
                safeRoadNumberList.add(safeRoadNumber);
            }
        }

        List<SafeRoadMapDto> safeRoadMapDtoList = new ArrayList<>();

        for (Long num : safeRoadNumberList) {
            SafeRoadMapDto safeRoadMapDto = new SafeRoadMapDto();
            List<SafeRoadPointDto> safeRoadPointDtoList = new ArrayList<>();
            List<SafeRoad> safeRoadList = safeRoadRepository.findBySafeRoadNumber(num);
            for (SafeRoad safeRoad : safeRoadList){
                SafeRoadPointDto safeRoadPointDto = new SafeRoadPointDto();
                safeRoadPointDto.setLng(safeRoad.getLongitude());
                safeRoadPointDto.setLat(safeRoad.getLatitude());
                safeRoadPointDtoList.add(safeRoadPointDto);

//                safeRoadMapDto.setAddress(safeRoad.getAddress());
            }

            safeRoadMapDto.setPoint(safeRoadPointDtoList);
//            safeRoadMapDto.setSafeRoadNumber(num);
            safeRoadMapDtoList.add(safeRoadMapDto);
        }

        return safeRoadMapDtoList;
    }

    public List<LocationRoadDto> getRiskRoad(String key, double centerLng, double centerLat, double radius) {
        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo().radius(key, new Circle(new Point(centerLng, centerLat), new Distance(radius, RedisGeoCommands.DistanceUnit.METERS)), args);

        List<LocationRoadDto> result = new ArrayList<>();
        LocationRoadDto road = new LocationRoadDto();

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            String member = geoResult.getContent().getName();
            List<List<Double>> coordinates = gson.fromJson(member, List.class);
            List<LocationDto> pointList = new ArrayList<>();
            for (List<Double> coordinate : coordinates) {
                double lng = coordinate.get(0);
                double lat = coordinate.get(1);
                LocationDto point = new LocationDto();
                point.setLng(lng);
                point.setLat(lat);
                pointList.add(point);
            }
            road.setPoint(pointList);
            result.add(road);
        }

        return result;
    }

}
