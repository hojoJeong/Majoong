package com.example.majoong.map.service;

import com.example.majoong.exception.NotExistShareLocationException;
import com.example.majoong.fcm.service.FCMService;
import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.map.dto.LocationShareDto;
import com.example.majoong.map.dto.LocationShareResponseDto;
import com.example.majoong.map.dto.MovingInfoDto;
import com.example.majoong.notification.domain.Notification;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.path.dto.PathInfoDto;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
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


@Slf4j
@RequiredArgsConstructor
@Service
public class MapService {

    private final NotificationService notificationService;

    private final RedisTemplate redisTemplate;

    private final UserRepository userRepository;

    private final FCMService fCMService;


    public void startMoving(LocationShareDto movingInfo) throws IOException {
        List<Integer> guardianIds;
        guardianIds = movingInfo.getGuardians();
        int userId = movingInfo.getUserId();
        User user = userRepository.findById(userId).get();
        // 보호자에게 알림 전송
        for (int guardianId : guardianIds) {

            Notification notification = new Notification(guardianId, userId, 2);
            notificationService.saveNotification(notification);

            String title = "[마중] 마중요청!";
            String body = user.getNickname()+"님이 마중을 요청했습니다.";

            fCMService.sendMessage(guardianId,title, body,title,body,"");
        }

        // redis 저장
        saveLocationInfo(userId, movingInfo);


    }
    public void saveLocationInfo(int userId, LocationShareDto movingInfo) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "guardians", String.valueOf(movingInfo.getGuardians()));
        hashOperations.put(key, "path", String.valueOf(movingInfo.getPath()));
    }


    public LocationShareDto getLocationInfo(int userId) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        Map<String, Object> hash = hashOperations.entries(key);
        if (hash.isEmpty()) {
            return null;
        }
        LocationShareDto movingInfo = new LocationShareDto();
        String guardiansStr = (String) hash.get("guardians");
        Gson gson = new Gson();
        Type type = new TypeToken<List<Integer>>(){}.getType();
        List<Integer> guardians = gson.fromJson(guardiansStr, type);
        movingInfo.setGuardians(guardians);

        String pathString = (String) hash.get("path");
        // 정규식 패턴 및 매칭
        Pattern distancePattern = Pattern.compile("distance=(\\d+)");
        Pattern timePattern = Pattern.compile("time=(\\d+)");
        Pattern locationPattern = Pattern.compile("LocationDto\\(lng=(\\d+\\.\\d+), lat=(\\d+\\.\\d+)\\)");

        Matcher distanceMatcher = distancePattern.matcher(pathString);
        Matcher timeMatcher = timePattern.matcher(pathString);
        Matcher locationMatcher = locationPattern.matcher(pathString);

        PathInfoDto pathInfo = new PathInfoDto();
        List<LocationDto> point = new ArrayList<>();
        if (distanceMatcher.find()) {
            pathInfo.setDistance(Integer.parseInt(distanceMatcher.group(1)));
        }
        if (timeMatcher.find()) {
            pathInfo.setTime(Integer.parseInt(timeMatcher.group(1)));
        }

        while (locationMatcher.find()) {
            LocationDto locationDto = new LocationDto();
            locationDto.setLng(Double.parseDouble(locationMatcher.group(1)));
            locationDto.setLat(Double.parseDouble(locationMatcher.group(2)));
            point.add(locationDto);
        }
        pathInfo.setPoint(point);
        movingInfo.setPath(pathInfo);
        movingInfo.setUserId(userId);
        return movingInfo;
    }


    public LocationShareResponseDto showSharedMoving(int userId) throws JsonProcessingException {
        LocationShareDto movingInfo = getLocationInfo(userId);
        if (movingInfo == null){
            throw new NotExistShareLocationException();
            }
        User user = userRepository.findById(userId).get();

        LocationShareResponseDto response = new LocationShareResponseDto();
        response.setNickname(user.getNickname());
        response.setPhoneNumber(user.getPhoneNumber());
        response.setPath(movingInfo.getPath());
        return response;
    }


    public void endMoving(int userId) {
        String key = "moving_location:" + userId;
        redisTemplate.delete(key);
    }

}