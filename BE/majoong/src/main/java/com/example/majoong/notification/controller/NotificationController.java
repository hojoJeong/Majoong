package com.example.majoong.notification.controller;

import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.response.ResponseData;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class NotificationController {

    private final NotificationService notificationService;
    @GetMapping("/notification/{userId}")
    public ResponseEntity getNotification(@PathVariable("userId") int userId){
        ResponseData data = new ResponseData();
        data.setData(notificationService.getNotificationsByToId(userId));
        return data.builder();
    }
}
