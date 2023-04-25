package com.example.majoong.map.domain;

import lombok.*;

import javax.persistence.*;

@Entity(name = "police")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Police {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long policeId;

    private float longitude;
    private float latitude;
    private String address;
}
