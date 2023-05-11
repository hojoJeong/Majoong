package com.example.majoong.path.domain;

import lombok.*;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

@Entity(name = "edge")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Edge {

    @Id
    @Column(name = "id", unique = true, nullable = false)
    private Long edgeId;
    private Long sourceId;
    private Long targetId;
    private int distanceVal;
    private int safeVal;
    private double centerLng;
    private double centerLat;
}
