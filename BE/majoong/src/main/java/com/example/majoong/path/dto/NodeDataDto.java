package com.example.majoong.path.dto;

import com.example.majoong.path.service.RecommendedPathService;
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

    public void calcF(Long endId, double endLng, double endLat) {
//        this.h = heuristic.get(endId);
        this.h = calcH(lng, lat, endLng, endLat);
        this.f = g + h;
    }

    // 구면 코사인 법칙 사용 거리 계산
    public double calcH(double startLng, double startLat, double endLng, double endLat){
        double theta = startLng - endLng;
        double distance = Math.sin(deg2rad(startLat)) * Math.sin(deg2rad(endLat)) + Math.cos(deg2rad(startLat)) * Math.cos(deg2rad(endLat)) * Math.cos(deg2rad(theta));

        distance = Math.acos(distance);
        distance = red2deg(distance);
        distance = distance * 60 * 1.1515 * 1609.344; // meter 단위로 변환

        return distance;
    }

    private double deg2rad(double deg) { return (deg * Math.PI / 180.0); }

    // convert radians to decimal degrees
    private double red2deg(double rad){
        return (rad * 180.0 / Math.PI);
    }
}