package com.example.majoong.notification.service;

import com.example.majoong.notification.domain.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@RequiredArgsConstructor
@Service
public class NotificationService {

    private final RedisTemplate redisTemplate;
    public void saveNotification(Notification notification) {

        String key = "notification:" + notification.getToId();

        HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "fromId", notification.getFromId());
        hashOperations.put(key, "type", notification.getType());
        hashOperations.put(key, "date", notification.getDate());

    }

    public void deleteNotification(Notification notification){

        String key = "notification:" + notification.getToId();
        String indexKey = notification.getFromId() + ":" + notification.getType() + ":" + notification.getDate();

        Map<String, String> notificationData = redisTemplate.opsForHash().entries(key);
        String indexData = notificationData.get("fromId") + ":" + notificationData.get("type") + ":" + notificationData.get("date");

        if (indexData.equals(indexKey)) {
            redisTemplate.delete(key);
        }

    }

}
