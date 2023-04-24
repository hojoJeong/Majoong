package com.example.majoong.user.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

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
    private String refreshToken;
    private long date;
    private int state;
    private String pinNumber;
    private boolean pushAlarm;
    private int alarmCount;

}
