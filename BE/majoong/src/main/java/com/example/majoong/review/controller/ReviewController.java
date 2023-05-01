package com.example.majoong.review.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.review.dto.CreateReviewDto;
import com.example.majoong.review.dto.DetailReviewDto;
import com.example.majoong.review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/map/review")
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{reviewId}")
    public ResponseEntity getMapReview(HttpServletRequest request, @PathVariable("reviewId") int reviewId) {
        ResponseData data = new ResponseData();
        DetailReviewDto detailReviewDto = reviewService.getDetailReview(request, reviewId);
        data.setData(detailReviewDto);
        data.setStatus(200);
        data.setMessage("리뷰 상세 조회 성공");
        return data.builder();
    }

    @PostMapping("")
    public ResponseEntity createMapReview(HttpServletRequest request,
                                          @RequestPart(value="longitude") double longitude,
                                          @RequestPart(value="latitude") double latitude,
                                          @RequestPart(value="address") String address,
                                          @RequestPart(value="score") int score,
                                          @RequestPart(value="isBright") boolean isBright,
                                          @RequestPart(value="isCrowded") boolean isCrowded,
                                          @RequestPart(value="content") String content,
                                          @RequestPart(value="reviewImage") MultipartFile reviewImage) {
        ResponseData data = new ResponseData();
        CreateReviewDto createReviewDto = new CreateReviewDto(longitude, latitude, address, score, isBright, isCrowded, content);
        try {
            reviewService.createReview(request, createReviewDto, reviewImage);
            data.setStatus(200);
            data.setMessage("리뷰 생성 성공");
            return data.builder();
        } catch (Exception e) {
            log.error("리뷰 생성 실패", e.getMessage());
            data.setStatus(400);
            data.setMessage("리뷰 생성 실패");
            return data.builder();
        }
    }
}