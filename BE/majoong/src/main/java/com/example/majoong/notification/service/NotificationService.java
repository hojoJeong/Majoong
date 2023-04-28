package com.example.majoong.notification.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class NotificationService {

    private final RedisTemplate redisTemplate;
    public void saveNotification(String toId, String fromId, String type) {

        String key = "notification:" + toId;

        HashOperations<String, String, String> hashOperations = redisTemplate.opsForHash();
        hashOperations.put(key, "fromId", fromId);
        hashOperations.put(key, "type", type);
    }

}
