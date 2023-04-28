package com.example.majoong.notification.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class Notification {

    String toId;
    String fromId;
    String type;

    public Notification(int toId, int fromId, int type) {
        this.toId = Integer.toString(toId);
        this.fromId = Integer.toString(fromId);
        this.type = Integer.toString(type);
    }
}
