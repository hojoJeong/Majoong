package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "police")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Police {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "police_id")
    private Long policeId;
    private double longitude;
    private double latitude;
    private String address;
}
