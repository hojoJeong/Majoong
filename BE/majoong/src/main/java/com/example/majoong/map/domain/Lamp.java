package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "lamp")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Lamp {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "lamp_id")
    private Long lampId;
    private double longitude;
    private double latitude;
    private String address;
}
