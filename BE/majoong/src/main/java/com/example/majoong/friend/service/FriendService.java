package com.example.majoong.friend.service;

import com.example.majoong.exception.ExistFriendException;
import com.example.majoong.exception.NotExistFriendRequestException;
import com.example.majoong.friend.domain.Friend;
import com.example.majoong.friend.dto.FriendDto;
import com.example.majoong.friend.dto.FriendRequestDto;
import com.example.majoong.friend.repository.FriendRepository;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;


@Service
@RequiredArgsConstructor
public class FriendService {

    @Autowired
    private FriendRepository friendRepository;

    @Autowired
    private UserRepository userRepository;
    public void sendFriendRequest(User user, User friend) {

        if (friendRepository.existsByUserAndFriendAndState(user, friend,0)) { //이미 친구요청 보낸 상태
            throw new ExistFriendException();
        }

        if (friendRepository.existsByUserAndFriendAndState(user, friend,1)) { //이미 친구
            throw new ExistFriendException();
        }

        Friend newFriend = new Friend(user, friend,0);
        friendRepository.save(newFriend);
    }

    public List<FriendDto> searchFriendRequests(int userId){
        User user = userRepository.findById(userId).get();
        List<Friend> friendRequests = friendRepository.findAllByFriendAndState(user,0);
        List<FriendDto> friends = new ArrayList<>();
        for (Friend friendRequest : friendRequests){
            FriendDto friend = new FriendDto();
            User requestFriend = friendRequest.getUser();
            friend.setUserId(requestFriend.getId());
            friend.setNickname(requestFriend.getNickname());
            friend.setPhoneNumber(requestFriend.getPhoneNumber());
            friend.setProfileImage(requestFriend.getProfileImage());
            friends.add(friend);
        }
        return friends;
    }

    public void acceptFriendRequest(User user, User friend){
        Friend friendInfo = friendRepository.findByUserAndFriendAndState(user, friend, 0);
        if (friendRepository.existsByUserAndFriendAndState(user, friend,1)) { //이미 친구
            throw new ExistFriendException();
        }
        if (friendInfo == null){
            throw new NotExistFriendRequestException();
        }
        friendInfo.setState(1);
        friendRepository.save(friendInfo);
    }
}
