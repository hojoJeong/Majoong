package com.example.majoong.review.domain;

import com.example.majoong.user.domain.User;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "review")
@Getter
@Setter
@EntityListeners(AuditingEntityListener.class)
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "review_id")
    private long reviewId;

    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonManagedReference
    private User user;

    private double longitude;
    private double latitude;
    private String address;
    private int score;
    private boolean isBright;
    private boolean isCrowded;
    private String content;
    private String reviewImage;
    @CreatedDate
    @Column(name = "created_at")
    private Date createdAt;
}
