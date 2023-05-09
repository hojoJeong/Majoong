package com.example.majoong.map.service;

import com.example.majoong.fcm.service.FCMService;
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

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor
@Service
public class MapService {

    private final NotificationService notificationService;

    private final RedisTemplate redisTemplate;

    private final UserRepository userRepository;

    private final FCMService fCMService;

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

    public void startMoving(LocationRequestDto movingInfo) throws IOException {
        List<Integer> guardianIds;
        guardianIds = movingInfo.getGuardians();
        int userId = movingInfo.getUserId();
        User user = userRepository.findById(userId).get();
        // 보호자에게 알림 전송
        for (int guardianId : guardianIds) {

            User guardian = userRepository.findById(guardianId).get();

            Notification notification = new Notification(guardianId, userId, 2);
            notificationService.saveNotification(notification);

            String title = "[마중] 마중요청!";
            String body = user.getNickname()+"님이 마중을 요청했습니다.";

            fCMService.sendMessage(guardian.getFcmToken(),title, body,title,body,"");
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

        List<LocationDto> path = getRecommendPath(movingInfo);

        List<Map<String, Object>> resultList = new ArrayList<>();
        hashOperations.put(key, "path", String.valueOf(path));

    }


    public MovingInfoDto getLocationInfo(int userId) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        Map<String, Object> hash = hashOperations.entries(key);
        if (hash.isEmpty()) {
            return null;
        }
        MovingInfoDto movingInfo = new MovingInfoDto();
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

        String path = (String) hash.get("path");
        List<Map<String, Object>> resultList = new ArrayList<>();
        path = path.replaceAll("LocationDto", "");

        Pattern pattern = Pattern.compile("\\(lng=(.*?), lat=(.*?)\\)");
        Matcher matcher = pattern.matcher(path);
        while (matcher.find()) {
            String lng = matcher.group(1);
            String lat = matcher.group(2);
            Map<String, Object> locationMap = new HashMap<>();
            locationMap.put("lng", Double.parseDouble(lng));
            locationMap.put("lat", Double.parseDouble(lat));
            resultList.add(locationMap);
        }
        movingInfo.setPath(resultList);
        return movingInfo;
    }


    public Map showSharedMoving(int userId) {
        MovingInfoDto movingInfo = getLocationInfo(userId);
        User user = userRepository.findById(userId).get();
        Map<String,Object> response = new HashMap<>();
        response.put("path",movingInfo.getPath());
        response.put("userId",userId);
        response.put("nickname",user.getNickname());
        response.put("phoneNumber",user.getPhoneNumber());
        return response;
    }


    public void endMoving(int userId) {
        String key = "moving_location:" + userId;
        redisTemplate.delete(key);
    }
}