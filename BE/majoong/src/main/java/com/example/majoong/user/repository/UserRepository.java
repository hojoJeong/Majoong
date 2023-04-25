package com.example.majoong.user.repository;

import com.example.majoong.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Integer> {

    User findByPhoneNumber(String phoneNumber);

    User findByRefreshToken(String token);

    User findByOauth(String oauth);


}
