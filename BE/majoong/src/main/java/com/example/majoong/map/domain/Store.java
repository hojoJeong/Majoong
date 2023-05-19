package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "store")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Store {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "store_id")
    private Long storeId;
    private double longitude;
    private double latitude;
    private String address;
}
