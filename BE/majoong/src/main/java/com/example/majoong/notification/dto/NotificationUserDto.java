package com.example.majoong.notification.dto;

import lombok.Data;

@Data
public class NotificationUserDto {
    String notificationId;
    int userId;
    String profileImage;
    String nickname;
    String phoneNumber;
    int type;
}
