package com.example.majoong.map.service;

import com.example.majoong.map.dto.*;
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

    private final RedisOperations<String, String> redisOperations;

    public MapFacilityResponseDto getMapFacilities(MapFacilityRequestDto position) {
        double centerLng = position.getCenterLng();
        double centerLat = position.getCenterLat();
        double radius = position.getRadius();

        MapFacilityResponseDto facilities = new MapFacilityResponseDto();

        facilities.setPolice(getFacilityDtos("police", centerLng, centerLat, radius, PoliceDto.class));
        facilities.setStore(getFacilityDtos("store", centerLng, centerLat, radius, StoreDto.class));
        facilities.setBell(getFacilityDtos("bell", centerLng, centerLat, radius, BellDto.class));
        facilities.setCctv(getFacilityDtos("cctv", centerLng, centerLat, radius, CctvDto.class));
        facilities.setReview(getFacilityDtos("review", centerLng, centerLat,radius, ReviewDto.class));
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
            else if (dto instanceof ReviewDto) ((ReviewDto) dto).setReviewId(Long.parseLong(id));

            dto.setLatitude(geoResult.getContent().getPoint().getY());
            dto.setLongitude(geoResult.getContent().getPoint().getX());
            dto.setAddress(address);
            dtos.add(dto);
        }
        return dtos;
    }
}
