package com.example.majoong.user.service;

import com.example.majoong.exception.DuplicatePhoneNumberException;
import com.example.majoong.exception.ExpiredNumberException;
import com.example.majoong.exception.WrongNumberException;
import com.example.majoong.fcm.service.FCMService;
import com.example.majoong.friend.domain.Friend;
import com.example.majoong.friend.repository.FriendRepository;
import com.example.majoong.notification.domain.Notification;
import com.example.majoong.notification.service.NotificationService;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.dto.*;
import com.example.majoong.user.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.apache.tomcat.util.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class MessageService {

    @Autowired
    private final UserRepository userRepository;

    @Autowired
    private final RedisTemplate redisTemplate;

    private final JwtTool jwtTool;

    private final FriendRepository friendRepository;

    private final NotificationService notificationService;

    private final FCMService fCMService;

    @Value("${naver.sms.service-id}")
    private String serviceId;

    @Value("${naver.secret-key}")
    private String secretKey;

    @Value("${naver.access-key}")
    private String accessKey;
    private String senderPhone="01075774492";
    public MessageResponseDto sendMessage(String phoneNumber) throws NoSuchAlgorithmException, InvalidKeyException, URISyntaxException, JsonProcessingException, UnsupportedEncodingException {
        User existingUser = userRepository.findByPhoneNumber(phoneNumber);
        if (existingUser != null) {
            throw new DuplicatePhoneNumberException();
        }
        Long time = System.currentTimeMillis();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-ncp-apigw-timestamp", time.toString());
        headers.set("x-ncp-iam-access-key", accessKey);
        headers.set("x-ncp-apigw-signature-v2", makeSignature(time));

        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 4; i++) {
            sb.append(random.nextInt(10));
        }
        String randomNumber = sb.toString();
        String content = "[majoong] 모바일 인증번호는 ["+randomNumber+"]입니다.";

        MessageDto message = new MessageDto();
        message.setTo(phoneNumber);
        message.setContent(content);
        List<MessageDto> messages = new ArrayList<>();
        messages.add(message);

        MessageRequestDto request = MessageRequestDto.builder()
                .type("SMS")
                .contentType("COMM")
                .countryCode("82")
                .from(senderPhone)
                .content(content)
                .messages(messages)
                .build();

        ObjectMapper objectMapper = new ObjectMapper();
        String body = objectMapper.writeValueAsString(request);
        HttpEntity<String> httpBody = new HttpEntity<>(body, headers);

        RestTemplate restTemplate = new RestTemplate();
        restTemplate.setRequestFactory(new HttpComponentsClientHttpRequestFactory());
        MessageResponseDto response =  restTemplate.postForObject(new URI("https://sens.apigw.ntruss.com/sms/v2/services/"+ serviceId +"/messages"), httpBody, MessageResponseDto.class);

        //인증번호 저장 (만료시간 5분)
        redisTemplate.opsForValue().set("phone:"+phoneNumber,randomNumber,Duration.ofMinutes(5));

        return response;
    }

    public boolean verifyNumber(VerificationNumberDto checkData){
        String verificationNumber = (String) redisTemplate.opsForValue().get("phone:"+checkData.getPhoneNumber());
        if (verificationNumber==null){
            throw new ExpiredNumberException();
        }

        if (verificationNumber.equals(checkData.getVerificationNumber())){
            return true;
        }
        else {
            throw new WrongNumberException();
        }


    }
    public String makeSignature(Long time) throws NoSuchAlgorithmException, UnsupportedEncodingException, InvalidKeyException {

        String message = new StringBuilder()
                .append("POST")
                .append(" ")
                .append("/sms/v2/services/"+ serviceId + "/messages")
                .append("\n")
                .append(time.toString())
                .append("\n")
                .append(accessKey)
                .toString();

        SecretKeySpec signingKey = new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(signingKey);

        byte[] rawHmac = mac.doFinal(message.getBytes("UTF-8"));
        String encodeBase64String = Base64.encodeBase64String(rawHmac);

        return encodeBase64String;
    }

    public MessageResponseDto send112Message(HttpServletRequest request, String content) throws NoSuchAlgorithmException, InvalidKeyException, URISyntaxException, IOException {
        Long time = System.currentTimeMillis();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-ncp-apigw-timestamp", time.toString());
        headers.set("x-ncp-iam-access-key", accessKey);
        headers.set("x-ncp-apigw-signature-v2", makeSignature(time));


        MessageDto message = new MessageDto();
        message.setTo("01092424723");
        message.setContent(content);
        List<MessageDto> messages = new ArrayList<>();
        messages.add(message);

        MessageRequestDto messageRequest = MessageRequestDto.builder()
                .type("SMS")
                .contentType("COMM")
                .countryCode("82")
                .from(senderPhone)
                .content(content)
                .messages(messages)
                .build();

        ObjectMapper objectMapper = new ObjectMapper();
        String body = objectMapper.writeValueAsString(messageRequest);
        HttpEntity<String> httpBody = new HttpEntity<>(body, headers);

        RestTemplate restTemplate = new RestTemplate();
        restTemplate.setRequestFactory(new HttpComponentsClientHttpRequestFactory());
        MessageResponseDto response =  restTemplate.postForObject(new URI("https://sens.apigw.ntruss.com/sms/v2/services/"+ serviceId +"/messages"), httpBody, MessageResponseDto.class);


        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);
        User user = userRepository.findById(userId).get();
        List<Friend> guardians = friendRepository.findAllByUserAndStateAndIsGuardian(user, 1, true);
        for (Friend guardian : guardians) {
            User guardianInfo = guardian.getFriend();
            int guardianId = guardianInfo.getId();
            Notification notification = new Notification(guardianId, userId, 2);
            notificationService.saveNotification(notification);

            String fcmTitle = "[마중] 마중요청!";
            String fcmBody = user.getNickname()+"님이 마중을 요청했습니다.";

            fCMService.sendMessage(guardianId,fcmTitle, fcmBody,fcmTitle,fcmBody,"");
        }


        return response;
    }


}
