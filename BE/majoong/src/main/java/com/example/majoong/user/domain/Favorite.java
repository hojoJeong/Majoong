package com.example.majoong.user.domain;

import com.example.majoong.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@NoArgsConstructor
@AllArgsConstructor
@Data
@Entity
@Table(name = "favorite_location")
public class Favorite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="favorite_id")
    private int id;
    private String address;
    private String locationName;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

}
