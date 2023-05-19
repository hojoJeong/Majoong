package com.example.majoong.path.domain;

import lombok.*;
import org.springframework.data.geo.Point;

import javax.persistence.*;

@Entity(name = "node")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Node {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long nodeId;
    private double lng;
    private double lat;
    private String address;

    @Transient
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point geom;
}