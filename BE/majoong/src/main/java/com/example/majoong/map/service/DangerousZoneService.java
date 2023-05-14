package com.example.majoong.map.service;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.map.dto.RoadDto;
import com.google.common.reflect.TypeToken;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DangerousZoneService {


    private final RedisOperations<String, String> redisOperations;

    private final Gson gson;


    public List<RoadDto> getAllRoadPoints() {
        List<RoadDto> points = new ArrayList<>();

        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo()
                .radius("50m_road_points", new Circle(new Point(128.41915,36.1033), new Distance(9999999999.0, RedisGeoCommands.DistanceUnit.METERS)), args);

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            RedisGeoCommands.GeoLocation<String> geoLocation = geoResult.getContent();
            Point geoPoint = geoLocation.getPoint();
            double longitude = geoPoint.getX();
            double latitude = geoPoint.getY();
            String[] member = geoResult.getContent().getName().split("_");
            int roadId = Integer.parseInt(member[0]);
            int id =Integer.parseInt(member[1]);
            RoadDto road = new RoadDto(id,roadId,longitude, latitude);
            points.add(road);
        }

        return points;
    }

    public List<List<RoadDto>> findRiskRoads() {
        System.out.println("시작");
        // 모든 도로 포인트 가져오기
        List<RoadDto> roadPoints = getAllRoadPoints();

        // 처리한 포인트들을 저장하는 Set
        Set<RoadDto> processedPoints = new HashSet<>();

        int len = roadPoints.size();

        List<List<RoadDto>> riskRoads = new ArrayList<>();
        Map<Integer, List<RoadDto>> roadIdMap = new HashMap<>();

        for (int i = 0; i < len; i++) {
            System.out.println(i);
            RoadDto roadPoint = roadPoints.get(i);

            if (processedPoints.contains(roadPoint)) {
                continue;
            }

            processedPoints.add(roadPoint);

            if (isFacility(roadPoint.getLng(), roadPoint.getLat())) {
                continue;
            }

            int roadId = roadPoint.getRoadId();
            List<RoadDto> roadIdPoints = roadIdMap.getOrDefault(roadId, new ArrayList<>());
            roadIdPoints.add(roadPoint);
            roadIdMap.put(roadId, roadIdPoints);
        }

        for (List<RoadDto> roadIdPoints : roadIdMap.values()) {
            if (roadIdPoints.size() >= 5) {
                riskRoads.add(roadIdPoints);
            }
        }

        return riskRoads;
    }


    public List<RoadDto> findRiskPoints() {
        // 모든 도로 포인트 가져오기
        List<RoadDto> roadPoints = getAllRoadPoints();

        // 처리한 포인트들을 저장하는 Set
        Set<RoadDto> processedPoints = new HashSet<>();

        int len = roadPoints.size();

        List<RoadDto> road = new ArrayList<>();
        for (int i = 0; i < len; i++) {
            System.out.println(i);
            RoadDto roadPoint = roadPoints.get(i);

            if (processedPoints.contains(roadPoint)) {
                continue;
            }

            processedPoints.add(roadPoint);

            if (isFacility(roadPoint.getLng(), roadPoint.getLat())) {
                continue;
            }
            road.add(roadPoint);
        }
        return road;
    }


    private boolean isFacility(double x, double y) {
        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();

        GeoResults<RedisGeoCommands.GeoLocation<String>> police = redisOperations.opsForGeo()
                .radius("police", new Circle(new Point(x, y), new Distance(500, RedisGeoCommands.DistanceUnit.METERS)), args);

        GeoResults<RedisGeoCommands.GeoLocation<String>> store = redisOperations.opsForGeo()
                .radius("store", new Circle(new Point(x, y), new Distance(150, RedisGeoCommands.DistanceUnit.METERS)), args);

        GeoResults<RedisGeoCommands.GeoLocation<String>> lamp = redisOperations.opsForGeo()
                .radius("lamp", new Circle(new Point(x, y), new Distance(5, RedisGeoCommands.DistanceUnit.METERS)), args);

        GeoResults<RedisGeoCommands.GeoLocation<String>> cctv = redisOperations.opsForGeo()
                .radius("cctv", new Circle(new Point(x, y), new Distance(10, RedisGeoCommands.DistanceUnit.METERS)), args);

        GeoResults<RedisGeoCommands.GeoLocation<String>> bell = redisOperations.opsForGeo()
                .radius("bell", new Circle(new Point(x, y), new Distance(5, RedisGeoCommands.DistanceUnit.METERS)), args);

        if (!police.getContent().isEmpty() || !store.getContent().isEmpty() || !lamp.getContent().isEmpty()
                || !cctv.getContent().isEmpty()|| !bell.getContent().isEmpty()) {
            return true;
        }
        return false;
    }




}


