package com.example.majoong.map.service;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.map.dto.RoadDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

@Slf4j
@Service
@RequiredArgsConstructor
public class DangerousZoneService {


    private final RedisOperations<String, String> redisOperations;



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

    private double calculateDistance(double lng1, double lat1, double lng2, double lat2) {
        // Haversine 공식을 사용한 거리 계산
        double earthRadius = 6371; // 지구 반지름 (단위: km)

        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        double distance = earthRadius * c;

        return distance;
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


