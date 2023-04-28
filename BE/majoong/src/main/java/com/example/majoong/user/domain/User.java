package com.example.majoong.user.domain;

import com.example.majoong.friend.domain.Friend;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.List;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Entity
@Table(name = "user")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="user_id")
    private int id;

    @Column(unique = true)
    private String phoneNumber;
    private String nickname;
    private String profileImage;
    private String fcmToken;
    @Column(unique = true)
    private String socialPK;
    private long date;
    private int state=1;
    private String pinNumber;
    private boolean pushAlarm=true;

    @PrePersist
    public void prePersist() {
        this.date = System.currentTimeMillis(); // 현재 시스템 시간으로 초기화
    }

}
