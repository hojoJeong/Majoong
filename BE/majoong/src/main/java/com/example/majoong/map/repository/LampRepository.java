package com.example.majoong.map.repository;

import com.example.majoong.map.domain.Lamp;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LampRepository extends JpaRepository<Lamp, Long> {
}
