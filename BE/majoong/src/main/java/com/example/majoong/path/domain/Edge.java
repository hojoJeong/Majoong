package com.example.majoong.path.domain;

import lombok.*;
import org.springframework.data.geo.Point;

import javax.persistence.*;

@Entity(name = "edge")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Edge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long edgeId;
    private Long sourceId;
    private double sourceLng;
    private double sourceLat;
    private Long targetId;
    private double targetLng;
    private double targetLat;
    private int safety;
    private String address;
    private double distance;
    private double centerLng;
    private double centerLat;

    @Transient
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point geom;
    @Transient
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point sourceGeom;
    @Transient
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point targetGeom;
}
