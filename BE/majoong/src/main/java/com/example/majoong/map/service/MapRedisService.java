package com.example.majoong.map.service;

import com.example.majoong.map.dto.PoliceDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Objects;

@Slf4j
@Service
@RequiredArgsConstructor
public class MapRedisService {

    private static final String CACHE_KEY = "POLICE";

    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;
    private HashOperations<String, String, String> hashOperations;

    @PostConstruct
    public void init() {
        this.hashOperations = redisTemplate.opsForHash();
    }

    public void save(PoliceDto policeDto) {
        if(Objects.isNull(policeDto) || Objects.isNull(policeDto.getPoliceId())) {
            log.error("value가 비었습니다.");
            return;
        }

        try {
            hashOperations.put(CACHE_KEY,
                    policeDto.getPoliceId().toString(),
                    serializePoliceDto(policeDto));
            log.info("저장성공", policeDto.getPoliceId());
        } catch (Exception e) {
            log.error("저장실패", e.getMessage());
        }
    }

    private String serializePoliceDto(PoliceDto policeDto) throws JsonProcessingException {
        return objectMapper.writeValueAsString(policeDto);
    }

    private PoliceDto deserializePoliceDto(String value) throws JsonProcessingException {
        return objectMapper.readValue(value, PoliceDto.class);
    }
}
