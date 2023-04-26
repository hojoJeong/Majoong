package com.example.majoong.user.service;

import com.example.majoong.exception.DuplicatePhoneNumberException;
import com.example.majoong.exception.ExpiredNumberException;
import com.example.majoong.exception.WrongNumberException;
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
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class MessageService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RedisTemplate redisTemplate;

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
        redisTemplate.opsForValue().set(phoneNumber,randomNumber,Duration.ofMinutes(5));

        return response;
    }

    public boolean verifyNumber(VerificationNumberDto checkData){
        String verificationNumber = (String) redisTemplate.opsForValue().get(checkData.getPhoneNumber());
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

    public void sendDataToRedis(AuthNumberDto info){
    }


}
