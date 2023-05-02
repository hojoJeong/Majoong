package com.example.majoong.user.domain;

import com.example.majoong.friend.domain.Friend;
import com.example.majoong.review.domain.Review;
import com.fasterxml.jackson.annotation.JsonBackReference;
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

    @JsonBackReference
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Review> reviewList;

    @PrePersist
    public void prePersist() {
        this.date = System.currentTimeMillis(); // 현재 시스템 시간으로 초기화
    }

}
