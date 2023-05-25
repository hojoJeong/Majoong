package com.example.majoong.path.repository;

import com.example.majoong.path.domain.Edge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface EdgeRepository extends JpaRepository<Edge, Long> {
    @Query(value = "SELECT * FROM edge WHERE ST_Within(sourcegeom, ST_MakeEnvelope(:lng1, :lat1, :lng2, :lat2, 4326)) AND ST_Within(targetgeom, ST_MakeEnvelope(:lng1, :lat1, :lng2, :lat2, 4326))", nativeQuery = true)
    List<Edge> findEdgesByArea(@Param("lng1") double lng1, @Param("lat1") double lat1, @Param("lng2") double lng2, @Param("lat2") double lat2);

    @Query(value = "SELECT * FROM edge WHERE edgeId = 3329661", nativeQuery = true)
    Edge findEdgePosition();

    @Query(value = "SELECT * FROM edge WHERE ST_Within(geom, ST_MakeEnvelope(128.09546, 36.02305, 128.47444, 36.26291, 4326))", nativeQuery = true)
    List<Edge> findEdgeList();
}
