package com.example.majoong.notification.service;

import com.example.majoong.notification.domain.Notification;
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
    public void saveNotification(Notification notification) {

        String key = "notification:" + notification.getId();

        HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "toId",notification.getToId());
        hashOperations.put(key, "fromId", notification.getFromId());
        hashOperations.put(key, "type", notification.getType());
        hashOperations.put(key, "date", notification.getDate());

    }

    public void deleteNotification(int toId, String notificationId) {
        String key = "notification:" + toId;

        redisTemplate.opsForHash().delete(key, "fromId", "type", "id", "date");
    }

    public List<Notification> getNotificationsByToId(int toId) {

        List<Notification> notifications = new ArrayList<>();

        Set<String> keys = redisTemplate.keys("notification:" + toId + "." + "*");

        for (String key : keys) {
            HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
            Map<String, String> map = hashOperations.entries(key);

            Notification notification = new Notification();
            notification.setId(key.substring(key.indexOf(":")+1));
            notification.setFromId(map.get("fromId"));
            notification.setToId(map.get("toId"));
            notification.setType(map.get("type"));
            notification.setDate(map.get("date"));

            notifications.add(notification);
        }

        return notifications;
    }




}
