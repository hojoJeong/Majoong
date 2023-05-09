package com.example.majoong.path.domain;

import lombok.*;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

@Entity(name = "node")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Node {
    @Id
    @Column(name = "id", unique = true, nullable = false)
    private Long nodeId;
    private double lng;
    private double lat;
    private String address;
}