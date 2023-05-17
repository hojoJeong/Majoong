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
    /*
    // 안전 시설물 점수 (전체 : 25)
    경찰서 : 10
    편의점 : 5
    cctv : 5
    안전귀갓길 : 3
    비상벨 : 1
    가로등 : 1
     */
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
