package com.example.majoong.map.repository;

import com.example.majoong.map.domain.SafeRoad;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SafeRoadRepository extends JpaRepository<SafeRoad, Long> {
    List<SafeRoad> findBySafeRoadNumber(Long safeRoadNumber);
}
