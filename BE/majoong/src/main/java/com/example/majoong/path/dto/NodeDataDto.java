package com.example.majoong.path.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class NodeDataDto {
    private Long nodeId;
    private double lng;
    private double lat;
    private Map<Long, Double> heuristic; // 다른 노드까지의 예상 비용 Map
    private double g;  // g is distance from the source // 출발지점부터 현재 노드까지의 비용
    private double h;  // h is the heuristic of destination.    // 목적지까지의 추정 비용
    private double f;  // f = g + h // 출발지부터의 비용과 목적지까지의 추정 비용의 합

    public NodeDataDto(Long nodeId, Map<Long, Double> heuristic, double lng, double lat){
        this.nodeId = nodeId;
        this.heuristic = heuristic;
        this.g = Double.MAX_VALUE;
        this.lng = lng;
        this.lat = lat;
    }

    public void calcF(Long destinationId) {
        this.h = heuristic.get(destinationId);
        this.f = g + h;
    }
}