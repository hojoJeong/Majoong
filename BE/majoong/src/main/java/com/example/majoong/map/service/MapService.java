package com.example.majoong.map.service;

import com.example.majoong.map.dto.LocationDto;
import com.example.majoong.map.dto.LocationRequestDto;
import com.example.majoong.map.dto.MovingInfoDto;
import com.example.majoong.notification.domain.Notification;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@RequiredArgsConstructor
@Service
public class MapService {

    private final NotificationService notificationService;

    private final RedisTemplate redisTemplate;

    private final UserRepository userRepository;

    public List<LocationDto> getRecommendPath(MovingInfoDto pathPoints) { //나중에 진짜 추천 경로로 대체 (지금 그냥 예시)
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

    public void startMoving(LocationRequestDto locationRequest) {
        List<Integer> guardianIds;
        guardianIds = locationRequest.getGuardians();
        int userId = locationRequest.getUserId();

        // 보호자에게 알림 전송
        for (int guardianId : guardianIds) {
            Notification notification = new Notification(guardianId, userId, 2);
            notificationService.saveNotification(notification);
        }

        // redis 저장
        MovingInfoDto movingInfo = new MovingInfoDto(locationRequest.getStartLng(),locationRequest.getStartLat(),locationRequest.getEndLat(),locationRequest.getEndLng(), locationRequest.isRecommended());
        saveLocationInfo(userId, movingInfo);



    }
    public void saveLocationInfo(int userId, MovingInfoDto movingInfo) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "startLng",movingInfo.getStartLng());
        hashOperations.put(key, "startLat", movingInfo.getStartLat());
        hashOperations.put(key, "endLng", movingInfo.getEndLng());
        hashOperations.put(key, "engLat", movingInfo.getEndLat());
        hashOperations.put(key, "isRecommend", movingInfo.isRecommend());
    }

    public MovingInfoDto getLocationInfo(int userId) {
        String key = "moving_location:" + userId;
        HashOperations hashOperations = redisTemplate.opsForHash();
        MovingInfoDto movingInfo = new MovingInfoDto();
        movingInfo.setStartLng((Double) hashOperations.get(key, "startLng"));
        movingInfo.setStartLat((Double) hashOperations.get(key, "startLat"));
        movingInfo.setEndLng((Double) hashOperations.get(key, "endLng"));
        movingInfo.setEndLat((Double) hashOperations.get(key, "endLat"));
        movingInfo.setRecommend((Boolean) hashOperations.get(key, "isRecommend"));
        return movingInfo;
    }


    public void showSharedMoving(int userId) {
        MovingInfoDto movingInfo = getLocationInfo(userId);
        List<LocationDto> path = getRecommendPath(movingInfo);
        User user = userRepository.findById(userId).get();
        Map<String,Object> response = new HashMap<>();
        response.put("path",path);
        response.put("userId",userId);
        response.put("nickname",user.getNickname());
        response.put("phoneNumber",user.getPhoneNumber());
    }
}