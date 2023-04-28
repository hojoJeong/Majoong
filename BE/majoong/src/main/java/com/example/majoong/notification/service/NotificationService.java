package com.example.majoong.notification.service;

import com.example.majoong.notification.domain.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class NotificationService {

    private final RedisTemplate redisTemplate;
    public void saveNotification(Notification notification) {

        String key = "notification:" + notification.getToId();

        HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "fromId", Integer.toString(notification.getFromId()));
        hashOperations.put(key, "type", Integer.toString(notification.getType()));
    }

}
