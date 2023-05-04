package com.example.majoong.video.service;


import com.example.majoong.exception.*;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.tools.UnitConverter;
import com.example.majoong.user.repository.UserRepository;
import com.example.majoong.video.dto.GetRecordingsResponseDto;
import com.example.majoong.video.dto.InitializeConnectionResponseDto;
import com.example.majoong.video.dto.InitializeSessionResponseDto;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.*;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

@Service
@RequiredArgsConstructor
public class VideoService {
    @Autowired
    private UserRepository userRepository;
    private final RedisTemplate redisTemplate;
    private final JwtTool jwtTool;
    private final UnitConverter unitConverter;


    @Value("${OPENVIDU_BASE_PATH}")
    private String OPENVIDU_BASE_PATH;

    @Value("${OPENVIDU_SECRET}")
    private String OPENVIDU_SECRET;

    public InitializeSessionResponseDto initializeSession(HttpServletRequest request){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        String url = OPENVIDU_BASE_PATH + "sessions";
        String customSessionId = userId + "-" + System.currentTimeMillis();
        String recordingMode = "ALWAYS";

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);
        // Body 생성
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("customSessionId",customSessionId);
        jsonObject.addProperty("recordingMode",recordingMode);
        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>(jsonObject.toString(), headers);
        // request
        ResponseEntity<String> response = restTemplate.exchange(
                url, //{요청할 서버 주소}
                HttpMethod.POST, //{요청할 방식}
                entity, // {요청할 때 보낼 데이터}
                String.class
        );

        // response
        JsonParser parser = new JsonParser();
        JsonObject responseBody = parser.parse(response.getBody()).getAsJsonObject();
        String sessionId = responseBody.get("id").getAsString();

        InitializeSessionResponseDto responseDto = new InitializeSessionResponseDto();
        responseDto.setSessionId(sessionId);
        return responseDto;
    }

    public void closeSession(HttpServletRequest request, String sessionId){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        //다른 사람이 세션을 종료하지 못하도록 예외 처리
        String[] splitId = sessionId.split("-");
        if (!splitId[0].equals(String.valueOf(userId))) {
            throw new InsufficientPermissionException();
        }

        String url = OPENVIDU_BASE_PATH + "sessions/" + sessionId;

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);

        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.DELETE, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 해당 세션이 존재하지 않는 경우
                throw new NotExistRecordingException();
            }
        }
    }

    public InitializeConnectionResponseDto initializeConnection(HttpServletRequest request, String sessionId){
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        String role = "SUBSCRIBER";
        String[] splitId = sessionId.split("-");
        if (splitId[0].equals(String.valueOf(userId))) {
            role = "PUBLISHER";
        }

        String url = OPENVIDU_BASE_PATH + "sessions/"+ sessionId + "/connection";
        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);
        // Body 생성
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("role",role);
        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>(jsonObject.toString(), headers);

        // request
        InitializeConnectionResponseDto responseDto = new InitializeConnectionResponseDto();
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.POST, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
            // response
            JsonParser parser = new JsonParser();
            JsonObject responseBody = parser.parse(response.getBody()).getAsJsonObject();
            String connectionId = responseBody.get("connectionId").getAsString();
            String connectionToken = responseBody.get("token").getAsString();

            responseDto.setConnectionId(connectionId);
            responseDto.setConnectionToken(connectionToken);

        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 해당 세션이 존재하지 않는 경우
                throw new NotExistSessionException();
            }
        }

        return responseDto;
    }

    public void closeConnection(String sessionId, String connectionId){

        String url = OPENVIDU_BASE_PATH + "sessions/" + sessionId + "/connection/" + connectionId;

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);

        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.DELETE, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 해당 커넥션이 존재하지 않는 경우
                throw new NotExistConnectionException();
            }
            else if (statusCode == HttpStatus.BAD_REQUEST) { //400: 해당 세션이 존재하지 않는 경우
                throw new NotExistSessionForConnectionException();
            }
        }
    }

    public List<GetRecordingsResponseDto> getRecordings(HttpServletRequest request){

        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        String url = OPENVIDU_BASE_PATH + "recordings";
        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);
        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        ResponseEntity<String> response = restTemplate.exchange(
                url, //{요청할 서버 주소}
                HttpMethod.GET, //{요청할 방식}
                entity, // {요청할 때 보낼 데이터}
                String.class
        );
        // response
        JsonParser parser = new JsonParser();
        JsonArray items = parser.parse(response.getBody()).getAsJsonObject().get("items").getAsJsonArray();
        // items를 순회하면서 userId와 일치하는 녹화파일 정보를 추출해서 List에 담습니다.
        List<GetRecordingsResponseDto> responseDtos = new ArrayList<>();
        for (JsonElement item : items) {
            String recordingId = item.getAsJsonObject().get("id").getAsString();
            String[] splitId = recordingId.split("-");
            if (splitId[0].equals(String.valueOf(userId))) {
                String createdAt = unitConverter.timestampToDate(item.getAsJsonObject().get("createdAt").getAsLong());
                long duration = item.getAsJsonObject().get("duration").getAsLong();
                String recordingUrl = null;
                String thumbnailImageUrl = null;
                if (!item.getAsJsonObject().get("url").isJsonNull()){ // 녹화가 진행중인 파일은 url이 존재하지 않아 예외처리함.
                    recordingUrl = item.getAsJsonObject().get("url").getAsString();
                    thumbnailImageUrl = recordingUrl.replace("mp4", "jpg");
                }


                GetRecordingsResponseDto responseDto = new GetRecordingsResponseDto();
                responseDto.setRecordingId(recordingId);
                responseDto.setThumbnailImageUrl(thumbnailImageUrl);
                responseDto.setRecordingUrl(recordingUrl);
                responseDto.setCreatedAt(createdAt);
                responseDto.setDuration(duration);
                responseDtos.add(responseDto);
            }
        }

        return responseDtos;
    }

    public void removeRecording(HttpServletRequest request, String recordingId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        //다른 사람이 세션을 종료하지 못하도록 예외 처리
        String[] splitId = recordingId.split("-");
        if (!splitId[0].equals(String.valueOf(userId))) {
            throw new InsufficientPermissionException();
        }
        String url = OPENVIDU_BASE_PATH + "recordings/" + recordingId;

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);

        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.DELETE, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 삭제할 녹황파일이 없는 경우
                throw new NotExistRecordingException();
            }
            else if (statusCode == HttpStatus.CONFLICT) {   //409: 녹화가 진행중인 경우
                throw new RecordingInProgressException();
            }
        }

    }

    public void startRecording(HttpServletRequest request, String sessionId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        //다른 사람이 녹화를 시작하지 못하도록 예외 처리
        String[] splitId = sessionId.split("-");
        if (!splitId[0].equals(String.valueOf(userId))) {
            throw new InsufficientPermissionException();
        }

        String url = OPENVIDU_BASE_PATH + "recordings/start";

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);
        // Body 생성
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("session", sessionId);
        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>(jsonObject.toString(), headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.POST, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 세션이 없는 경우
                throw new NotExistSessionException();
            }
            else if (statusCode == HttpStatus.NOT_ACCEPTABLE) {   //406: 세션에 연결된 참여자가 없는 경우
                throw new NoConnectedParticipantsException();
            }
            else if (statusCode == HttpStatus.CONFLICT) {   //409: 이미 녹화중인 경우
                throw new RecordingInProgressException();
            }
        }

    }

    public void stopRecording(HttpServletRequest request, String sessionId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        //다른 사람이 녹화를 종료하지 못하도록 예외 처리
        String[] splitId = sessionId.split("-");
        if (!splitId[0].equals(String.valueOf(userId))) {
            throw new InsufficientPermissionException();
        }

        String url = OPENVIDU_BASE_PATH + "recordings/stop/" + sessionId;

        // OPENVIDU REST API 요청
        RestTemplate restTemplate = new RestTemplate(new HttpComponentsClientHttpRequestFactory());
        // Header 생성
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.add("Authorization", "Basic " + OPENVIDU_SECRET);

        // Header + Body
        HttpEntity<String> entity = new HttpEntity<String>("", headers);
        // request
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, //{요청할 서버 주소}
                    HttpMethod.POST, //{요청할 방식}
                    entity, // {요청할 때 보낼 데이터}
                    String.class
            );
        }
        catch (HttpClientErrorException | HttpServerErrorException e){
            HttpStatus statusCode = e.getStatusCode();

            if (statusCode == HttpStatus.NOT_FOUND){        //404: 녹화 파일이 없는 경우
                throw new NotExistRecordingException();
            }
            else if (statusCode == HttpStatus.NOT_ACCEPTABLE) {   //406: 녹화가 starting인 경우 (started 상태여야 녹화 중단 가능)
                throw new RecordingNotStartedException();
            }
        }

    }

}
