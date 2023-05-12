package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity(name = "lamp")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Lamp {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long lampId;
    private double longitude;
    private double latitude;
    private String address;
}
