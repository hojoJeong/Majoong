package com.example.majoong.friend.controller;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.friend.dto.FriendDto;
import com.example.majoong.friend.dto.FriendNameDto;
import com.example.majoong.friend.dto.FriendRequestDto;
import com.example.majoong.friend.service.FriendService;
import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "친구 API", description = "친구 요청, 요청 관리, 친구 ")
@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class FriendController {

    private final FriendService friendService;

    @Autowired
    private UserRepository userRepository;

    private final JwtTool jwtTool;

    @Operation(summary = "친구요청", description = "친구요청 API")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "친구요청 목록", description = "사용자가 받은 친구 요청 목록을 모두 불러옵니다.")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "친구요청 수락", description = "친구요청 수락 API")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "친구요청 거절", description = "친구요청 거절 API")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "친구 삭제", description = "친구 삭제시 친구 관계가 쌍방으로 삭제됩니다.")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "친구 목록 조회 (친구, 보호자)", description = "isGuardian : 0 보호자 아닌 친구, 1 : 보호자")
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
        log.info("");
        return data.builder();
    }

    @Operation(summary = "보호자 등록/해제", description = "현재상태가 보호자면 해제, 아니면 등록합니다.")
    @PutMapping("/guardian")
    public ResponseEntity changeIsGuardian(@RequestBody FriendRequestDto friendInfo){
        log.info("/user/guardian @Put start");
        User user = userRepository.findById(friendInfo.getUserId()).orElseThrow(() -> new NoUserException());
        User friend = userRepository.findById(friendInfo.getFriendId()).orElseThrow(() -> new NoUserException());
        friendService.changeIsGuardian(user,friend);
        ResponseData data = new ResponseData();
        log.info("/user/guardian end\n");
        log.info("");
        return data.builder();
    }
    @Operation(summary = "친구 별칭 수정", description = "기본값은 친구 닉네임으로, 별명을 수정할 때 사용하는 API")
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
        log.info("");
        return data.builder();
    }
}
