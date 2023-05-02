package com.example.majoong.friend.controller;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.friend.domain.Friend;
import com.example.majoong.friend.dto.FriendDto;
import com.example.majoong.friend.dto.FriendNameDto;
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

import javax.security.auth.message.AuthException;
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
        log.info("/user/friend @Post start");
        User user = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.sendFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구요청 완료");
        log.info(data.toString());
        log.info("/user/friend end\n");
        return data.builder();
    }

    @GetMapping("/friendrequests")
    public ResponseEntity searchFriendRequests(HttpServletRequest request) {
        log.info("/user/friendrequests @Get start");
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        List<FriendDto> friendrequests = friendService.searchFriendRequests(userId);
        ResponseData data = new ResponseData();
        data.setData(friendrequests);
        log.info(data.toString());
        log.info("/user/friendrequests end\n");
        return data.builder();
    }

    @PostMapping("/friend/accept")
    public ResponseEntity acceptFriendRequest(@RequestBody FriendRequestDto friendRequest){
        log.info("/user/friend/accept @Post start");
        User friend = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User user = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.acceptFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구 수락");
        log.info(data.toString());
        log.info("/user/friend/accept end\n");
        return data.builder();
    }

    @PostMapping("/friend/deny")
    public ResponseEntity denyFriendRequest(@RequestBody FriendRequestDto friendRequest){
        log.info("/user/friend/deny @Post start");
        User friend = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User user = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.denyFriendRequest(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구요청 삭제");
        log.info(data.toString());
        log.info("/user/friend/deny end\n");
        return data.builder();
    }

    @DeleteMapping("/friend")
    public ResponseEntity deleteFriend(@RequestBody FriendRequestDto friendRequest){
        log.info("/user/friend @Delete start");
        User user = userRepository.findById(friendRequest.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendRequest.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.deleteFriend(user, friend);
        ResponseData data = new ResponseData();
        data.setMessage("친구 삭제");
        log.info(data.toString());
        log.info("/user/friend end\n");
        return data.builder();
    }
    @GetMapping("/friends/{isGuardian}")
    public ResponseEntity getFriendsList(HttpServletRequest request, @PathVariable("isGuardian") boolean isGuardian) {
        log.info("/user/friends/{isGuardian} @Get start");
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        List<FriendDto> friends = friendService.getFriendsList(userId, isGuardian);
        ResponseData data = new ResponseData();
        data.setData(friends);
        log.info(data.toString());
        log.info("/user/friends/{isGuardian} end\n");
        return data.builder();
    }

    @PutMapping("/guardian")
    public ResponseEntity changeIsGuardian(@RequestBody FriendRequestDto friendInfo){
        log.info("/user/guardian @Put start");
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
        log.info(data.toString());
        log.info("/user/guardian end\n");
        return data.builder();
    }

    @PutMapping("/friend")
    public ResponseEntity changeFriendName(@RequestBody FriendNameDto friendNameDto){
        log.info("/user/friend @Put start");
        User user = userRepository.findById(friendNameDto.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendNameDto.getFriendId()).orElseThrow(() -> new NoUserException());
        FriendDto newFriendInfo = friendService.changeFriendName(user,friend, friendNameDto.getFriendName());
        ResponseData data = new ResponseData();
        data.setMessage("친구 이름 변경");
        data.setData(newFriendInfo);
        log.info(data.toString());
        log.info("/user/friend end\n");
        return data.builder();
    }
}
