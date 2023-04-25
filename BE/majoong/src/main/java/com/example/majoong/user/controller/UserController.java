package com.example.majoong.user.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.dto.CreateUserDto;
import com.example.majoong.user.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


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
}
