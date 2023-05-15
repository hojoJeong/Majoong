package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "bell")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Bell {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "bell_id")
    private Long bellId;
    private double longitude;
    private double latitude;
    private String address;
}
