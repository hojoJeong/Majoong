package com.example.majoong.friend.repository;

import com.example.majoong.friend.domain.Friend;
import com.example.majoong.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FriendRepository extends JpaRepository<Friend, Integer> {
    boolean existsByUserAndFriendAndState(User user, User friend, int state);
    List<Friend> findAllByFriendAndState(User friend, int state);
    Friend findByUserAndFriendAndState(User user, User friend, int state);
}
