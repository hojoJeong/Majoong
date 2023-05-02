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

    @PostMapping(value="",
            consumes = {
                    MediaType.MULTIPART_FORM_DATA_VALUE,
                    MediaType.APPLICATION_JSON_VALUE
            })
    public ResponseEntity createMapReview(HttpServletRequest request,
//                                          @RequestPart("createReviewDto") CreateReviewDto createReviewDto,
                                          @RequestPart("lng") double longitude,
                                          @RequestPart("lat") double latitude,
                                          @RequestPart("address") String address,
                                          @RequestPart("score") int score,
                                          @RequestPart("isBright") boolean isBright,
                                          @RequestPart("isCrowded") boolean isCrowded,
                                          @RequestPart("content") String content,
                                          @RequestPart("reviewImage") MultipartFile reviewImage) {

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