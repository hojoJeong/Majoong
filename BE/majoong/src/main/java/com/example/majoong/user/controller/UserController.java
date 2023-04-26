package com.example.majoong.user.controller;

import com.example.majoong.exception.RefreshTokenException;
import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;


@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class UserController {
    private final UserService userService;
    @GetMapping
    public ResponseEntity userList() {
        ResponseData data = new ResponseData();
        data.setData(userService.getUserList());
        data.setMessage("회원정보 조회 성공");
        return data.builder();
    }
    @PostMapping("/signup")
    public ResponseEntity joinUser(@RequestBody CreateUserDto user){
        ResponseData data = new ResponseData();
        userService.createUser(user);
        data.setStatus(200);
        data.setMessage("회원가입 성공");
        return data.builder();
    }


    @PostMapping("/login")
    public ResponseEntity login(@RequestBody LoginDto info) {
        ResponseUserDto user = userService.Login(info);
        ResponseData data = new ResponseData();
        data.setData(user);
        data.setMessage("로그인 성공");
        return data.builder();
    }

    @PostMapping("/retoken")
    public ResponseEntity reToken(@RequestBody ReTokenDto token) {
        TokenDto newToken = userService.reToken(token);
        ResponseData data = new ResponseData();
        data.setData(newToken);
        data.setMessage("토큰 재발행 성공");
        return data.builder();
    }

    @GetMapping("/test")
    public ResponseEntity test() {
        ResponseData data = new ResponseData();
        data.setData("하잉~");
        return data.builder();
    }

    @PostMapping("withdrawal")
    public ResponseEntity withdrawal(HttpServletRequest request) {
        ResponseData data = new ResponseData();
        data.setMessage(userService.withdrawal(request));
        return data.builder();
    }

}
