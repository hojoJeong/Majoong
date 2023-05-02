package com.example.majoong.notification.controller;

import com.example.majoong.notification.dto.NotificationIdDto;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;

@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class NotificationController {
    private final JwtTool jwtTool;
    private final NotificationService notificationService;
    @GetMapping("/notification")
    public ResponseEntity getNotification(HttpServletRequest request){
        log.info("/user/notification @Get start");
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        ResponseData data = new ResponseData();
        data.setData(notificationService.getNotificationsByToId(userId));
        log.info(data.toString());
        log.info("/user/notification end\n");
        return data.builder();
    }

    @DeleteMapping("/notification")
    public ResponseEntity getNotification(@RequestBody NotificationIdDto notificationIdDto){
        log.info("/user/notification @Delete start");
        notificationService.deleteNotification(notificationIdDto.getNotificationId());
        ResponseData data = new ResponseData();
        log.info(data.toString());
        log.info("/user/notification end\n");
        return data.builder();
    }
}
