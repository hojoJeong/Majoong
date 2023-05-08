package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NodeDto {
    private Long nodeId;
    private double lng;
    private double lat;
    private double g;  // g is distance from the source // 출발지점부터 현재 노드까지의 비용
    private double h;  // h is the heuristic of destination.    // 목적지까지의 추정 비용
    private double f;  // f = g + h // 출발지부터의 비용과 목적지까지의 추정 비용의 합

    public void calcF(Long target) {
        Map<Long, Double> temp = heuristic;
        this.h = temp.get(target);
        this.f = g + h;
    }
}
