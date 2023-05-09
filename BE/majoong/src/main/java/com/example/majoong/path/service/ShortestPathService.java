package com.example.majoong.path.service;

import com.example.majoong.path.dto.NodeDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ShortestPathService {

    @Value("${google.maps.api.key}")
    private String API_KEY;
    private String API_URL = "https://";

    public List<NodeDto> getShortestPath(double startLng, double startLat, double endLng, double endLat) {

        List<NodeDto> shortestPath = new ArrayList<>();

        return shortestPath;
    }
}
