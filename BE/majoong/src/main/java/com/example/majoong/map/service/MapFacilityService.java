package com.example.majoong.map.service;

import com.example.majoong.map.domain.SafeRoad;
import com.example.majoong.map.dto.*;
import com.example.majoong.map.repository.SafeRoadRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.algorithm.ConvexHull;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.Geometry;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.MultiPoint;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.RedisOperations;
import org.springframework.stereotype.Service;

import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapFacilityService {

    private final Gson gson;

    private final RedisOperations<String, String> redisOperations;
    private final SafeRoadRepository safeRoadRepository;

    public MapFacilityResponseDto getMapFacilities(MapFacilityRequestDto position) throws JsonProcessingException {
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
        facilities.setRiskRoad(getRiskPolygon("risk_polygon", centerLng, centerLat, radius));
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
        Set<String> processedRoads = new HashSet<>(); // 중복 체크를 위한 Set

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            String roadName = geoResult.getContent().getName();

            if (!processedRoads.contains(roadName)) {
                LocationRoadDto road = new LocationRoadDto();
                List<LocationDto> list = new ArrayList<>();

                String[] member = roadName.split("_");
                LocationDto start = new LocationDto();
                start.setLng(Double.parseDouble(member[0]));
                start.setLat(Double.parseDouble(member[1]));
                list.add(start);
                LocationDto end = new LocationDto();
                end.setLng(Double.parseDouble(member[2]));
                end.setLat(Double.parseDouble(member[3]));
                list.add(end);
                road.setPoint(list);
                result.add(road);
                processedRoads.add(roadName);
            }
        }

        return result;
    }

    public List<LocationRoadDto> getRiskPolygon(String key, double centerLng, double centerLat, double radius) throws JsonProcessingException {
        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo().radius(key, new Circle(new Point(centerLng, centerLat), new Distance(radius, RedisGeoCommands.DistanceUnit.METERS)), args);

        List<LocationRoadDto> result = new ArrayList<>();
        Set<String> processed = new HashSet<>(); // 중복 체크를 위한 Set

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            RedisGeoCommands.GeoLocation<String> location = geoResult.getContent();
            String polygon = location.getName();

            if (processed.contains(polygon)) {
                continue;
            }

            ObjectMapper objectMapper = new ObjectMapper();
            List<Double[]> coordinates = objectMapper.readValue(polygon, new TypeReference<List<Double[]>>() {});

            List<LocationDto> locationList = new ArrayList<>();
            for (Double[] coordinate : coordinates) {
                LocationDto locationDto = new LocationDto();
                locationDto.setLng(coordinate[0]);
                locationDto.setLat(coordinate[1]);
                locationList.add(locationDto);
            }

            LocationRoadDto roadDto = new LocationRoadDto();
            roadDto.setPoint(locationList);
            result.add(roadDto);
        }

        return result;
    }

    public List<LocationDto> getAllRoadLocations(int distance) {
        List<LocationDto> points = new ArrayList<>();

        RedisGeoCommands.GeoRadiusCommandArgs args = RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeCoordinates().includeDistance();
        GeoResults<RedisGeoCommands.GeoLocation<String>> geoResults = redisOperations.opsForGeo()
                .radius("50m_road_points", new Circle(new Point(128.41915,36.1033), new Distance(distance, RedisGeoCommands.DistanceUnit.METERS)), args);

        for (GeoResult<RedisGeoCommands.GeoLocation<String>> geoResult : geoResults) {
            RedisGeoCommands.GeoLocation<String> geoLocation = geoResult.getContent();
            Point geoPoint = geoLocation.getPoint();
            double longitude = geoPoint.getX();
            double latitude = geoPoint.getY();
            LocationDto road = new LocationDto(longitude, latitude);
            points.add(road);
        }

        return points;
    }

    public List<LocationDto> findRiskPoints(int distance) {
        // 모든 도로 포인트 가져오기
        List<LocationDto> roadPoints = getAllRoadLocations(distance);

        // 처리한 포인트들을 저장하는 Set
        Set<LocationDto> processedPoints = new HashSet<>();

        int len = roadPoints.size();

        List<LocationDto> road = new ArrayList<>();
        for (int i = 0; i < len; i++) {
            LocationDto roadPoint = roadPoints.get(i);

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

        GeoResults<RedisGeoCommands.GeoLocation<String>> lamp = redisOperations.opsForGeo()
                .radius("lamp", new Circle(new Point(x, y), new Distance(5, RedisGeoCommands.DistanceUnit.METERS)), args);

        if (!lamp.getContent().isEmpty()){
            return true;
        }

        GeoResults<RedisGeoCommands.GeoLocation<String>> store = redisOperations.opsForGeo()
                .radius("store", new Circle(new Point(x, y), new Distance(150, RedisGeoCommands.DistanceUnit.METERS)), args);

        if (!store.getContent().isEmpty()){
            return true;
        }


        GeoResults<RedisGeoCommands.GeoLocation<String>> police = redisOperations.opsForGeo()
                .radius("police", new Circle(new Point(x, y), new Distance(500, RedisGeoCommands.DistanceUnit.METERS)), args);

        if (!police.getContent().isEmpty()){
            return true;
        }

        GeoResults<RedisGeoCommands.GeoLocation<String>> cctv = redisOperations.opsForGeo()
                .radius("cctv", new Circle(new Point(x, y), new Distance(10, RedisGeoCommands.DistanceUnit.METERS)), args);
        if (!cctv.getContent().isEmpty()){
            return true;
        }

        GeoResults<RedisGeoCommands.GeoLocation<String>> bell = redisOperations.opsForGeo()
                .radius("bell", new Circle(new Point(x, y), new Distance(5, RedisGeoCommands.DistanceUnit.METERS)), args);
        if (!bell.getContent().isEmpty()){
            return true;
        }

        return false;
    }


    public List<LocationRoadDto> getPolygonsWithOuterPoints(int distance) {
        List<LocationDto> points = findRiskPoints(distance);
        List<List<LocationDto>> groups = new ArrayList<>();

        for (LocationDto point : points) {
            boolean addedToGroup = false;

            // 기존 그룹들과 비교하여 적절한 그룹에 추가
            for (List<LocationDto> group : groups) {
                if (isCloseToGroup(point, group)) {
                    group.add(point);
                    addedToGroup = true;
                    break;
                }
            }

            // 새로운 그룹 생성
            if (!addedToGroup) {
                List<LocationDto> newGroup = new ArrayList<>();
                newGroup.add(point);
                groups.add(newGroup);
            }
        }

        // 3개 미만의 그룹 제거
        groups.removeIf(group -> group.size() < 3);

        // 각 그룹에서 가장 외곽의 포인트들만 추출
        List<LocationRoadDto> polygons = new ArrayList<>();
        for (List<LocationDto> group : groups) {
            List<LocationDto> outerPoints = findOuterPoints(group);

            LocationRoadDto roadDto = new LocationRoadDto();
            roadDto.setPoint(outerPoints);

            polygons.add(roadDto);
        }

        return polygons;
    }


    private List<LocationDto> findOuterPoints(List<LocationDto> group) {
        // LocationDto를 Coordinate로 변환
        Coordinate[] coordinates = group.stream()
                .map(location -> new Coordinate(location.getLng(), location.getLat()))
                .toArray(Coordinate[]::new);

        // MultiPoint 생성
        GeometryFactory geometryFactory = new GeometryFactory();
        MultiPoint multiPoint = geometryFactory.createMultiPointFromCoords(coordinates);

        // 볼록 껍질 계산
        ConvexHull convexHull = new ConvexHull(multiPoint);
        Coordinate[] hullPoints = convexHull.getConvexHull().getCoordinates();

        // 결과 반환
        List<LocationDto> outerPoints = Arrays.stream(hullPoints)
                .map(point -> new LocationDto(point.getX(), point.getY()))
                .collect(Collectors.toList());

        return outerPoints;
    }


    private boolean isCloseToGroup(LocationDto point, List<LocationDto> group) {
        for (LocationDto groupPoint : group) {
            double distanceBetweenPoints = calculateDistance(point, groupPoint);
            if (distanceBetweenPoints >= 200.0) {
                return false;
            }
        }
        return true;
    }

    private double calculateDistance(LocationDto point1, LocationDto point2) {
        double lng1 = point1.getLng();
        double lat1 = point1.getLat();
        double lng2 = point2.getLng();
        double lat2 = point2.getLat();

        // 좌표 간의 거리 계산
        double earthRadius = 6371.0; // 지구 반지름 (단위: km)

        double dLng = Math.toRadians(lng2 - lng1);
        double dLat = Math.toRadians(lat2 - lat1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        double distance = earthRadius * c;
        return distance*1000;
    }

}
