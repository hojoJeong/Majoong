package com.example.majoong.map.service;

import com.example.majoong.map.dto.LocationDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DangerousZoneService {


    private final RedisOperations<String, String> redisOperations;



    public List<LocationDto> getAllRoadPoints() {
        List<LocationDto> points = new ArrayList<>();

        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo()
                .radius("road_points", new Circle(new Point(0.0, 0.0), new Distance(9999999999.0, RedisGeoCommands.DistanceUnit.METERS)), args);

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            RedisGeoCommands.GeoLocation<String> geoLocation = geoResult.getContent();
            Point geoPoint = geoLocation.getPoint();
            Double longitude = geoPoint.getX();
            Double latitude = geoPoint.getY();
            LocationDto location = new LocationDto(longitude, latitude);
            points.add(location);
        }

        return points;
    }

    }


