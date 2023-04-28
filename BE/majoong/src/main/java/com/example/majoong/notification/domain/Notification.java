package com.example.majoong.notification.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@NoArgsConstructor
@AllArgsConstructor
@Data
public class Notification {

    String id; //notificationId
    String toId; //알림받은사람
    String fromId; //알림보낸사람
    String type; //1:친구요청, 2:마중요청
    String date=Long.toString(System.currentTimeMillis());

    public Notification(int toId, int fromId, int type) {
        this.toId = Integer.toString(toId);
        this.fromId = Integer.toString(fromId);
        this.type = Integer.toString(type);
        this.id = this.toId + "_" + this.fromId +"_"+ this.type +"_"+ date;
    }
}
