package com.example.majoong.user.repository;

import com.example.majoong.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    User findByPhoneNumber(String phoneNumber);

    User findBySocialPK(String socialPK);

}
