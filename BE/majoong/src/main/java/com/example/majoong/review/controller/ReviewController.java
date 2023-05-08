package com.example.majoong.review.controller;

import com.example.majoong.response.ResponseData;
import com.example.majoong.review.dto.CreateReviewDto;
import com.example.majoong.review.dto.DetailReviewDto;
import com.example.majoong.review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Nullable;
import javax.servlet.http.HttpServletRequest;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/map/review")
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/{reviewId}")
    public ResponseEntity getMapReview(HttpServletRequest request, @PathVariable("reviewId") long reviewId) {
        ResponseData data = new ResponseData();
        DetailReviewDto detailReviewDto = reviewService.getDetailReview(request, reviewId);
        data.setData(detailReviewDto);
        data.setStatus(200);
        data.setMessage("리뷰 상세 조회 성공");
        return data.builder();
    }

    @PostMapping(value="")
    public ResponseEntity createMapReview(HttpServletRequest request,
//                                          @RequestBody CreateReviewDto createReviewDto,
                                          @RequestPart("lng") String longitude,
                                          @RequestPart("lat") String latitude,
                                          @RequestPart("address") String address,
                                          @RequestPart("score") String score,
                                          @RequestPart("isBright") String isBright,
                                          @RequestPart("isCrowded") String isCrowded,
                                          @RequestPart("content") String content,
                                          @Nullable @RequestPart("reviewImage") MultipartFile reviewImage) {

        ResponseData data = new ResponseData();
//        log.info("requestPart 전달 확인 : {}", createReviewDto.getLongitude());
        log.info("requestPart 전달 확인 : {}", longitude);
        CreateReviewDto createReviewDto = new CreateReviewDto(
                Double.parseDouble(longitude),
                Double.parseDouble(latitude),
                address,
                Integer.parseInt(score) ,
                Boolean.parseBoolean(isBright),
                Boolean.parseBoolean(isCrowded),
                content);
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

    @DeleteMapping("/{reviewId}")
    public ResponseEntity deleteMapReview(HttpServletRequest request, @PathVariable("reviewId") int reviewId) {
        ResponseData data = new ResponseData();
        try {
            reviewService.deleteReview(request, reviewId);
            log.info("리뷰 삭제 성공");
            data.setStatus(200);
            data.setMessage("리뷰 삭제 성공");
            return data.builder();
        } catch (Exception e) {
            log.error("리뷰 삭제 실패", e.getMessage());
            data.setStatus(400);
            data.setMessage("리뷰 삭제 실패");
            return data.builder();
        }
    }
}