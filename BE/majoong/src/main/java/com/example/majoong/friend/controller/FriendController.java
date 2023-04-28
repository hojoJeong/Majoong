package com.example.majoong.friend.controller;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.friend.domain.Friend;
import com.example.majoong.friend.dto.FriendDto;
import com.example.majoong.friend.dto.FriendRequestDto;
import com.example.majoong.friend.service.FriendService;
import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class FriendController {

    private final FriendService friendService;

    @Autowired
    private UserRepository userRepository;

    private final JwtTool jwtTool;

    @PostMapping("/friend")
    public ResponseEntity sendFriendRequest(@RequestBody FriendRequestDto friendRequest) {
        User user = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.sendFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구요청 완료");
        return data.builder();
    }

    @GetMapping("/friendrequests")
    public ResponseEntity searchFriendRequests(HttpServletRequest request) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        List<FriendDto> friendrequests = friendService.searchFriendRequests(userId);
        ResponseData data = new ResponseData();
        data.setData(friendrequests);
        return data.builder();
    }

    @PostMapping("/friend/accept")
    public ResponseEntity acceptFriendRequest(@RequestBody FriendRequestDto friendRequest){
        User friend = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User user = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.acceptFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구 수락");
        return data.builder();
    }

    @PostMapping("/friend/deny")
    public ResponseEntity denyFriendRequest(@RequestBody FriendRequestDto friendRequest){
        User friend = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User user = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.denyFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구요청 삭제");
        return data.builder();
    }

    @DeleteMapping("/friend")
    public ResponseEntity deleteFriend(@RequestBody FriendRequestDto friendRequest){
        User user = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.deleteFriend(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구 삭제");
        return data.builder();
    }
    @GetMapping("/friends/{isGuardian}")
    public ResponseEntity getFriendsList(HttpServletRequest request, @PathVariable("isGuardian") boolean isGuardian) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        List<FriendDto> friends = friendService.getFriendsList(userId, isGuardian);
        ResponseData data = new ResponseData();
        data.setData(friends);
        return data.builder();
    }

    @PutMapping("/guardian")
    public ResponseEntity changeIsGuardian(@RequestBody FriendRequestDto friendInfo){
        User user = userRepository.findById(friendInfo.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendInfo.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.changeIsGuardian(user,friend);
        ResponseData data = new ResponseData();
        Map<String, Object> allFriendsList = new HashMap<>();
        List<FriendDto> friendsNotGuardian = friendService.getFriendsList(user.getId(), false);
        List<FriendDto> guardians = friendService.getFriendsList(user.getId(), true);
        allFriendsList.put("friends",friendsNotGuardian);
        allFriendsList.put("guardians", guardians);
        data.setData(allFriendsList);
        return data.builder();
    }

}
