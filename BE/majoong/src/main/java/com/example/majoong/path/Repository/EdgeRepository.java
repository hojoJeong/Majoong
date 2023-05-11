package com.example.majoong.path.Repository;

import com.example.majoong.path.domain.Edge;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface EdgeRepository extends JpaRepository<Edge, Long> {
    @Query(value = "SELECT * FROM edge WHERE ST_Within(ST_MakePoint(centerLng, centerLat), ST_MakeEnvelope(:lng1, :lat1, :lng2, :lat2, 4326))", nativeQuery = true)
    List<Edge> findEdgesByArea(@Param("lng1") double lng1, @Param("lat1") double lat1, @Param("lng2") double lng2, @Param("lat2") double lat2);
}
