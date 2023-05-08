package com.example.majoong.user.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.service.MessageService;
import com.example.majoong.user.service.UserService;
import com.fasterxml.jackson.core.JsonProcessingException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import static java.rmi.server.LogStream.log;

@Tag(name = "회원 API", description = "로그인, 가입, 휴대폰인증, 탈퇴, 토큰")
@RequestMapping("/user")
@RequiredArgsConstructor
@RestController
@Slf4j
public class UserController {
    private final UserService userService;
    private final MessageService messageService;


    @GetMapping
    public ResponseEntity getUser(HttpServletRequest request) {
        log.info("/user @Get start");
        ResponseData data = new ResponseData();
        data.setData(userService.getUser(request));
        data.setMessage("회원정보 조회 성공");
        log.info(data.toString());
        log.info("/user end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "회원가입", description = "회원가입 API")
    @PostMapping("/signup")
    public ResponseEntity joinUser(@RequestBody CreateUserDto user){
        log.info("/user/signup @Post start");
        ResponseData data = new ResponseData();
        userService.signupUser(user);
        data.setStatus(200);
        data.setMessage("회원가입 성공");
        log.info(data.toString());
        log.info("/user/signup end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "로그인", description = "소셜 계정 PK로 로그인")
    @PostMapping("/login")
    public ResponseEntity login(@RequestBody LoginDto info) {
        UserResponseDto user = userService.login(info.getSocialPK());
        log.info("/user/login @Post start");
        ResponseData data = new ResponseData();
        data.setData(user);
        data.setMessage("로그인 성공");
        log.info(data.toString());
        log.info("/user/login end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "자동로그인", description = "AccessToken으로 자동로그인")
    @PostMapping("/auto-login")
    public ResponseEntity autoLogin(HttpServletRequest request) {
        UserResponseDto user = userService.autoLogin(request);
        log.info("/user/auto-login @Post start");
        ResponseData data = new ResponseData();
        data.setData(user);
        data.setMessage("자동 로그인");
        log.info(data.toString());
        log.info("/user/auto-login end\n");
        log.info("");
        return data.builder();
    }
    @PostMapping("/withdrawal")
    public ResponseEntity withdrawal(HttpServletRequest request) {
        log.info("/user/withdrawal @Post start");
        ResponseData data = new ResponseData();
        data.setMessage(userService.withdrawal(request));
        log.info(data.toString());
        log.info("/user/withdrawal end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "토큰 재발급", description = "RefreshToken을 받아 AccessToken 재발급")
    @PostMapping("/retoken")
    public ResponseEntity reToken(HttpServletRequest request) {
        log.info("/user/retoken @Post start");
        TokenDto newToken = userService.reToken(request);
        ResponseData data = new ResponseData();
        data.setData(newToken);
        data.setMessage("AccessToken 재발행 성공");
        log.info(data.toString());
        log.info("/user/retoken end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "휴대폰 인증번호 전송", description = "인증번호를 전송합니다.")
    @PostMapping("/phone")
    public ResponseEntity<?> sendAuthNumber(@RequestBody PhoneNumberDto info) throws NoSuchAlgorithmException, URISyntaxException, InvalidKeyException, JsonProcessingException, UnsupportedEncodingException {
        log.info("/user/phone @Post start");
        ResponseData data = new ResponseData();
        data.setData(messageService.sendMessage(info.getPhoneNumber()));
        log.info(data.toString());
        log.info("/user/phone end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "휴대폰 인증번호 확인", description = "인증번호를 확인합니다.")
    @PostMapping("/phone/verify")
    public ResponseEntity<?> verifyAuthNumber(@RequestBody VerificationNumberDto info) {
        log.info("/user/phone/verify @Post start");
        ResponseData data = new ResponseData();
        if (messageService.verifyNumber(info)){
            data.setMessage("인증 완료");
        }
        log.info(data.toString());
        log.info("/user/phone/verify end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "휴대폰 인증번호 전송", description = "인증번호를 전송합니다.")
    @PostMapping("/phone112")
    public ResponseEntity<?> sendAuthNumber(@RequestBody Map<String,String> message) throws NoSuchAlgorithmException, URISyntaxException, InvalidKeyException, JsonProcessingException, UnsupportedEncodingException {
        log.info("/user/phone112 @Post start");
        ResponseData data = new ResponseData();
        data.setData(messageService.sendContentMessage(message.get("content")));
        log.info(data.toString());
        log.info("/user/phone112 end\n");
        log.info("");
        return data.builder();
    }

    @PutMapping("/pin")
    @Operation(summary = "pinNumber 수정", description = "pinNumber 수정 API 입니다.")
    public ResponseEntity<?> changePin(HttpServletRequest request, @RequestBody pinNumberDto info) {
        log.info("/user/pin @Put start");
        ResponseData data = new ResponseData();
        data.setData(userService.changePin(request, info.getPinNumber()));
        data.setMessage("pin 수정 성공");
        log.info(data.toString());
        log.info("/user/pin end\n");
        log.info("");

        return data.builder();
    }

    @PutMapping("/profile")
    public ResponseEntity<?> changeProfile(HttpServletRequest request,
                                           @RequestPart("nickname") String nickname,
                                           @RequestPart("phoneNumber") String phoneNumber,
                                           @RequestPart("profileImage") MultipartFile profileImage) throws IOException {
        log.info("/user/profile @Put start");
        ResponseData data = new ResponseData();
        UserProfileRequestrDto userProfileRequestrDto = new UserProfileRequestrDto();
        userProfileRequestrDto.setPhoneNumber(phoneNumber);
        userProfileRequestrDto.setNickname(nickname);

        data.setData(userService.changeProfile(request, userProfileRequestrDto, profileImage));
        data.setMessage("회원정보 수정 성공");
        log.info(data.toString());
        log.info("/user/profile end\n");
        log.info("");
        return data.builder();
    }

    @Operation(summary = "회원 검색", description = "휴대폰 번호로 회원 검색")
    @PostMapping("/search")
    public ResponseEntity searchPhonenumber(@RequestBody PhoneNumberDto info) {
        log.info("/user/search @Post start");
        ResponseData data = new ResponseData();
        data.setData(userService.searchPhoneNumber(info.getPhoneNumber()));
        log.info(data.toString());
        log.info("/user/search end\n");
        log.info("");
        return data.builder();
    }

}
