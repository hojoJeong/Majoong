package com.example.majoong.tools;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
@Service
public class UnitConverter {
    public String timestampToDate(long timestamp){
// Instant 객체 생성
        Instant instant = Instant.ofEpochMilli(timestamp);

// Instant 객체를 LocalDateTime 객체로 변환
        LocalDateTime localDateTime = LocalDateTime.ofInstant(instant, ZoneId.systemDefault());

// 변환된 LocalDateTime 객체를 원하는 형식으로 출력
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formattedDateTime = localDateTime.format(formatter);

        return formattedDateTime;
    }

    public String secondToMinuteSecond(double seconds){
        int minutes = (int) seconds / 60;  // 분으로 변환
        int remainingSeconds = (int) seconds % 60;  // 초로 변환

        return minutes + ":" + remainingSeconds;
    }
}
