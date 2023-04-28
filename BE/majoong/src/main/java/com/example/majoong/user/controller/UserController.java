package com.example.majoong.user.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.service.MessageService;
import com.example.majoong.user.service.UserService;
import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import javax.servlet.http.HttpServletRequest;


@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class UserController {
    private final UserService userService;
    private final MessageService messageService;

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
        userService.signupUser(user);
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

    @PostMapping("/withdrawal")
    public ResponseEntity withdrawal(HttpServletRequest request) {
        ResponseData data = new ResponseData();
        data.setMessage(userService.withdrawal(request));
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


    @PostMapping("/phone")
    public ResponseEntity<?> sendAuthNumber(@RequestBody PhoneNumberDto info) throws NoSuchAlgorithmException, URISyntaxException, InvalidKeyException, JsonProcessingException, UnsupportedEncodingException {
        ResponseData data = new ResponseData();
        data.setData(messageService.sendMessage(info.getPhoneNumber()));
        return data.builder();
    }

    @PostMapping("/phone/verify")
    public ResponseEntity<?> verifyAuthNumber(@RequestBody VerificationNumberDto info) {
        ResponseData data = new ResponseData();
        if (messageService.verifyNumber(info)){
            data.setMessage("인증 완료");
        }
        return data.builder();
    }


}
