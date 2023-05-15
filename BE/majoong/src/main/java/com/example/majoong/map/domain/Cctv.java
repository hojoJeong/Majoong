package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "cctv")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Cctv {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cctv_id")
    private Long cctvId;
    private double longitude;
    private double latitude;
    private String address;
}
