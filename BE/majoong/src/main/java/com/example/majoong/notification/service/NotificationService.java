package com.example.majoong.notification.service;

import com.example.majoong.notification.domain.Notification;
import com.example.majoong.notification.dto.NotificationUserDto;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RequiredArgsConstructor
@Service
public class NotificationService {

    private final RedisTemplate redisTemplate;

    private final UserRepository userRepository;
    public void saveNotification(Notification notification) {

        String key = "notification:" + notification.getId();

        HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "toId",notification.getToId());
        hashOperations.put(key, "fromId", notification.getFromId());
        hashOperations.put(key, "type", notification.getType());
        hashOperations.put(key, "date", notification.getDate());

    }

    public void deleteNotification(String notificationId) {
        String key = "notification:" + notificationId;
        redisTemplate.delete(key);
    }

    public List<NotificationUserDto> getNotificationsByToId(int toId) {

        List<NotificationUserDto> notifications = new ArrayList<>();

        Set<String> keys = redisTemplate.keys("notification:" + toId+"_"+"*");
        for (String key : keys) {
            HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
            Map<String, String> map = hashOperations.entries(key);
            User user = userRepository.findById(Integer.parseInt(map.get("fromId"))).orElse(null);
            if (user == null){
                continue;
            }
            NotificationUserDto notificationUser = new NotificationUserDto();
            notificationUser.setNotificationId(key.substring(key.indexOf(":")+1));
            notificationUser.setUserId(user.getId());
            notificationUser.setNickname(user.getNickname());
            notificationUser.setProfileImage(user.getProfileImage());
            notificationUser.setPhoneNumber(user.getPhoneNumber());
            notificationUser.setType(Integer.parseInt(map.get("type")));
            notifications.add(notificationUser);
        }

        return notifications;
    }




}
