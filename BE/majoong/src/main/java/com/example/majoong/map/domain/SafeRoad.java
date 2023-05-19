package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "saferoad")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SafeRoad {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "safe_road_id")
    private Long safeRoadId;
    private double longitude;
    private double latitude;
    private String address;
    @Column(name = "safe_road_number")
    private Long safeRoadNumber;
}
