package com.example.majoong.map.service;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.map.dto.LocationRequestDto;
import com.example.majoong.map.dto.MovingInfoDto;
import com.example.majoong.notification.domain.Notification;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor
@Service
public class MapService {

    private final NotificationService notificationService;

    private final RedisTemplate redisTemplate;

    private final UserRepository userRepository;

    public List<LocationDto> getRecommendPath(LocationRequestDto pathPoints) { //나중에 진짜 추천 경로로 대체 (지금 그냥 예시)
        List<Map<String, Double>> points = new ArrayList<>();
        Map<String, Double> point1 = new HashMap<>();
        point1.put("lng", pathPoints.getStartLng());
        point1.put("lat", pathPoints.getStartLat());
        points.add(point1);

        Map<String, Double> point2 = new HashMap<>();
        point2.put("lng", 127.0468);
        point2.put("lat", 37.5744);
        points.add(point2);

        Map<String, Double> point3 = new HashMap<>();
        point3.put("lng", pathPoints.getEndLng());
        point3.put("lat", pathPoints.getEndLat());
        points.add(point3);

        List<LocationDto> pointDtos = new ArrayList<>();

        for (Map<String, Double> point : points) {
            LocationDto pointDto = new LocationDto(point.get("lng"), point.get("lat"));
            pointDtos.add(pointDto);
        }

        return pointDtos;
    }

    public void startMoving(LocationRequestDto movingInfo) {
        List<Integer> guardianIds;
        guardianIds = movingInfo.getGuardians();
        int userId = movingInfo.getUserId();

        // 보호자에게 알림 전송
        for (int guardianId : guardianIds) {
            Notification notification = new Notification(guardianId, userId, 2);
            notificationService.saveNotification(notification);
        }

        // redis 저장
        saveLocationInfo(userId, movingInfo);

    }
    public void saveLocationInfo(int userId, LocationRequestDto movingInfo) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "guardians", String.valueOf(movingInfo.getGuardians()));
        hashOperations.put(key, "isRecommend", String.valueOf(movingInfo.getIsRecommend()));
        hashOperations.put(key, "startLng", String.valueOf(movingInfo.getStartLng()));
        hashOperations.put(key, "startLat", String.valueOf(movingInfo.getStartLat()));
        hashOperations.put(key, "endLng", String.valueOf(movingInfo.getEndLng()));
        hashOperations.put(key, "endLat", String.valueOf(movingInfo.getEndLat()));
    }


    public LocationRequestDto getLocationInfo(int userId) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        Map<String, Object> hash = hashOperations.entries(key);
        if (hash.isEmpty()) {
            return null;
        }
        LocationRequestDto movingInfo = new LocationRequestDto();
        String guardiansStr = (String) hash.get("guardians");
        Gson gson = new Gson();
        Type type = new TypeToken<List<Integer>>(){}.getType();
        List<Integer> guardians = gson.fromJson(guardiansStr, type);
        movingInfo.setGuardians(guardians);
        movingInfo.setIsRecommend(Boolean.parseBoolean((String)hash.get("isRecommend")));
        movingInfo.setStartLng(Double.parseDouble((String) hash.get("startLng")));
        movingInfo.setStartLat(Double.parseDouble((String) hash.get("startLat")));
        movingInfo.setEndLng(Double.parseDouble((String) hash.get("endLng")));
        movingInfo.setEndLat(Double.parseDouble((String) hash.get("endLat")));
        System.out.println(movingInfo);
        return movingInfo;
    }


    public Map showSharedMoving(int userId) {
        LocationRequestDto movingInfo = getLocationInfo(userId);
        List<LocationDto> path = getRecommendPath(movingInfo);
        User user = userRepository.findById(userId).get();
        Map<String,Object> response = new HashMap<>();
        response.put("path",path);
        response.put("userId",userId);
        response.put("nickname",user.getNickname());
        String phoneNumber = user.getPhoneNumber();
        if (phoneNumber != null && phoneNumber.length() == 11) {
            phoneNumber = phoneNumber.substring(0, 3) + "-" + phoneNumber.substring(3, 7) + "-" + phoneNumber.substring(7);
        }
        response.put("phoneNumber",phoneNumber);
        return response;
    }

    public void endSharedMoving(int userId){
        String key = "moving_location:" + userId;
        redisTemplate.delete(key);
    }
}