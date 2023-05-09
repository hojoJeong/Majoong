package com.example.majoong.video.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.user.service.UserService;
import com.example.majoong.video.dto.GetRecordingsResponseDto;
import com.example.majoong.video.dto.InitializeConnectionResponseDto;
import com.example.majoong.video.dto.InitializeSessionResponseDto;
import com.example.majoong.video.dto.StartVideoResponseDto;
import com.example.majoong.video.service.VideoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Tag(name = "비디오 API", description = "세션 관리, 연결, 녹화")
@RequestMapping("/video")
@RequiredArgsConstructor
@RestController
@Slf4j
public class VideoController {

    private final VideoService videoService;

    @PostMapping("/start")
    @Operation(summary = "session 생성", description = "session을 생성합니다.")
    public ResponseEntity<?> videoStart(HttpServletRequest request) {
        StartVideoResponseDto responseDto = new StartVideoResponseDto();

        // 세션 생성
        InitializeSessionResponseDto responseDto1 = videoService.initializeSession(request);
        String sessionId = responseDto1.getSessionId();

        // 연결 생성
        InitializeConnectionResponseDto responseDto2 = videoService.initializeConnection(request, sessionId);
        String connectionId = responseDto2.getConnectionId() ;
        String connectionToken = responseDto2.getConnectionToken();

        responseDto.setSessionId(sessionId);
        responseDto.setConnectionId(connectionId);
        responseDto.setConnectionToken(connectionToken);

        ResponseData data = new ResponseData();
        data.setData(responseDto);
        data.setMessage("videoStart 성공");

        return data.builder();
    }

    @PostMapping("/sessions")
    @Operation(summary = "session 생성", description = "session을 생성합니다.")
    public ResponseEntity<?> initializeSession(HttpServletRequest request) {

        InitializeSessionResponseDto responseDto = videoService.initializeSession(request);

        ResponseData data = new ResponseData();
        data.setData(responseDto);
        data.setMessage("initializeSession 성공");

        return data.builder();
    }

    @DeleteMapping("/sessions/{sessionId}")
    @Operation(summary = "session 삭제", description = "session을 삭제합니다. 세션에 대한 모든 connection도 삭제합니다.")
    public ResponseEntity<?> closeSession(HttpServletRequest request, @PathVariable("sessionId") String sessionId) {

        videoService.closeSession(request, sessionId);
        ResponseData data = new ResponseData();
        data.setMessage("closeSession 성공");
        return data.builder();
    }

//    @PostMapping("/sessions/{sessionId}/connection")
//    @Operation(summary = "connection 생성", description = "특정 session에 대한 connection을 생성합니다.")
//    public ResponseEntity<?> initializeConnection(HttpServletRequest request, @PathVariable("sessionId")String sessionId) {
//
//        InitializeConnectionResponseDto responseDto = videoService.initializeConnection(request, sessionId);
//
//        ResponseData data = new ResponseData();
//        data.setData(responseDto);
//        data.setMessage("initializeConnection 성공");
//        return data.builder();
//    }
    @PostMapping("/connection/{sessionId}")
    @Operation(summary = "connection 생성", description = "특정 session에 대한 connection을 생성합니다.")
    public ResponseEntity<?> initializeConnection(HttpServletRequest request, @PathVariable("sessionId")String sessionId) {

        InitializeConnectionResponseDto responseDto = videoService.initializeConnection(request, sessionId);

        ResponseData data = new ResponseData();
        data.setData(responseDto);
        data.setMessage("initializeConnection 성공");
        return data.builder();
    }

    @DeleteMapping("/sessions/{sessionId}/connection/{connectionId}")
    @Operation(summary = "connection 삭제", description = "특정 session에 대한 특정한 connection을 삭제합니다.")
    public ResponseEntity<?> closeConnection(@PathVariable("sessionId")String sessionId, @PathVariable("connectionId")String connectionId) {
        videoService.closeConnection(sessionId, connectionId);
        ResponseData data = new ResponseData();
        data.setMessage("closeConnection 성공");
        return data.builder();
    }

    @PostMapping("/recordings/start/{sessionId}")
    @Operation(summary = "recording 시작", description = "특정 세션에서 녹화를 시작합니다.")
    public ResponseEntity<?> startRecording(HttpServletRequest request, @PathVariable("sessionId") String sessionId) {

        videoService.startRecording(request, sessionId);

        ResponseData data = new ResponseData();
        data.setMessage("startRecording 성공");
        return data.builder();
    }

    @PostMapping("/recordings/stop/{sessionId}")
    @Operation(summary = "recording 종료", description = "특정 세션에서 녹화를 종료합니다.")
    public ResponseEntity<?> stopRecording(HttpServletRequest request, @PathVariable("sessionId") String sessionId) {

        videoService.stopRecording(request, sessionId);

        ResponseData data = new ResponseData();
        data.setMessage("stopRecording 성공");
        return data.builder();
    }

    @GetMapping("/recordings")
    @Operation(summary = "recording 목록 조회", description = "유저의 녹화목록을 조회합니다.")

    public ResponseEntity<?> getRecordings(HttpServletRequest request) {
        List<GetRecordingsResponseDto> responseDtos = videoService.getRecordings(request);

        ResponseData data = new ResponseData();
        data.setData(responseDtos);
        data.setMessage("getRecordings 성공");
        return data.builder();
    }

    @DeleteMapping("/recordings/{recordingId}")
    @Operation(summary = "recording 삭제", description = "녹화파일을 삭제합니다.")

    public ResponseEntity<?> removeRecording(HttpServletRequest request, @PathVariable("recordingId") String recordingId) {
        videoService.removeRecording(request, recordingId);
        ResponseData data = new ResponseData();
        data.setMessage("removeRecording 성공");
        return data.builder();
    }

}
