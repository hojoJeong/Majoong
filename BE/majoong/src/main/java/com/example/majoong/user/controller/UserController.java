package com.example.majoong.user.controller;

import com.example.majoong.exception.JwtException;
import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class UserController {
    private final UserService userService;
    private final JwtTool jwtTool;

    @PostMapping("/signup")
    public ResponseEntity<?> joinUser(@RequestBody CreateUserDto user){
        ResponseData data = new ResponseData();
        userService.createUser(user);
        data.setStatus(200);
        data.setMessage("회원가입 성공");
        return data.builder();
    }


    @PostMapping("/login/kakao")
    public ResponseUserDto KakaoLogin(@RequestBody KakaoLoginDto info) {
        ResponseUserDto user = userService.KakaoLogin(info);
        return user;
    }

    @PostMapping("/retoken")
    public ResponseEntity<?> reToken(@RequestBody ReTokenDto token) {
        if(token.getRefreshToken() == null
                || token.getRefreshToken().split(" ").length != 2
                || !jwtTool.validateToken(token.getRefreshToken())) {
            throw new JwtException();
        }

        TokenDto user = userService.generateUser(token.getId());
        ResponseData data = new ResponseData();
        data.setData(user);
        return data.builder();
    }

}
