package com.example.majoong.user.repository;

import com.example.majoong.user.domain.Favorite;
import com.example.majoong.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FavoriteRepository extends JpaRepository<Favorite, Integer> {

    List<Favorite> findAllByUser(User user);
}
