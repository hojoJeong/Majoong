package com.example.majoong.video.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.user.service.UserService;
import com.example.majoong.video.dto.GetRecordingsResponseDto;
import com.example.majoong.video.dto.InitializeSessionResponseDto;
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

    @PostMapping("/sessions")
    @Operation(summary = "session 생성", description = "session을 생성합니다.")
    public ResponseEntity<?> initializeSession(HttpServletRequest request) {

        InitializeSessionResponseDto responseDto = videoService.initializeSession(request);

        ResponseData data = new ResponseData();
        data.setData(responseDto);
        data.setMessage("session 생성 성공");

        return data.builder();
    }

    @DeleteMapping("/sessions/{sessionId}")
    @Operation(summary = "session 삭제", description = "session을 삭제합니다. 세션에 대한 모든 connection도 삭제합니다.")
    public ResponseEntity<?> closeSession(@PathVariable("sessionId") String sessionId) {

        videoService.closeSession(sessionId);
        ResponseData data = new ResponseData();
        data.setMessage("session 삭제 성공");
        return data.builder();
    }

    @PostMapping("/sessions/{sessionId}/connection")
    @Operation(summary = "connection 생성", description = "특정 session에 대한 connection을 생성합니다.")
    public ResponseEntity<?> initializeConnection() {

        ResponseData data = new ResponseData();
        return data.builder();
    }

    @DeleteMapping("/sessions/{sessionId}/connection/{connectionId}")
    @Operation(summary = "connection 삭제", description = "특정 session에 대한 특정한 connection을 삭제합니다.")
    public ResponseEntity<?> closeConnection() {

        ResponseData data = new ResponseData();
        return data.builder();
    }
    @PostMapping("/recordings/start/{sessionId}")
    @Operation(summary = "recording 시작", description = "특정 세션에서 녹화를 시작합니다.")
    public ResponseEntity<?> startRecording(@PathVariable("sessionId") String sessionId) {

        ResponseData data = new ResponseData();
        return data.builder();
    }

    @PostMapping("/recordings/stop/{sessionId}")
    @Operation(summary = "recording 종료", description = "특정 세션에서 녹화를 종료합니다.")
    public ResponseEntity<?> stopRecording(@PathVariable("sessionId") String sessionId) {

        ResponseData data = new ResponseData();
        return data.builder();
    }
    @GetMapping("/recordings")
    @Operation(summary = "recording 목록 조회", description = "유저의 녹화목록을 조회합니다.")

    public ResponseEntity<?> getRecordings(HttpServletRequest request) {
        List<GetRecordingsResponseDto> responseDtos = videoService.getRecordings(request);

        ResponseData data = new ResponseData();
        data.setData(responseDtos);
        data.setMessage("녹화 목록 조회");
        return data.builder();
    }

    @DeleteMapping("/recordings/{recordingId}")
    @Operation(summary = "recording 삭제", description = "녹화파일을 삭제합니다.")

    public ResponseEntity<?> removeRecording(@PathVariable("recordingId") String recordingId) {
        videoService.removeRecording(recordingId);
        ResponseData data = new ResponseData();
        data.setMessage("녹화파일 삭제");
        return data.builder();
    }
}
