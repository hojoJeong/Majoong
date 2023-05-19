package com.example.majoong.review.service;

import com.example.majoong.exception.NoReviewException;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.review.domain.Review;
import com.example.majoong.review.dto.CreateReviewDto;
import com.example.majoong.review.dto.DetailReviewDto;
import com.example.majoong.review.repository.ReviewRepository;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.tools.S3Upload;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.core.GeoOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewService {

    @Autowired
    private final UserRepository userRepository;
    @Autowired
    private final ReviewRepository reviewRepository;
    private final RedisTemplate redisTemplate;
    private final JwtTool jwtTool;
    private final S3Upload s3Upload;


    public DetailReviewDto getDetailReview(HttpServletRequest request, long reviewId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> optionalUser = userRepository.findById(userId);
        if (!optionalUser.isPresent()) {
            log.error("존재하지 않는 유저 입니다. : {}", userId);
            throw new NoUserException();
        }
        Optional<Review> optionalReview = reviewRepository.findById(reviewId);
        if (!optionalReview.isPresent()) {
            log.error("존재하지 않는 리뷰 입니다. : {}", reviewId);
            throw new NoReviewException();
        }

        Review review = optionalReview.get();
        DetailReviewDto detailReviewDto = new DetailReviewDto();
        detailReviewDto.setReviewId(review.getReviewId());
        detailReviewDto.setAddress(review.getAddress());
        detailReviewDto.setScore(review.getScore());
        detailReviewDto.setBright(review.isBright());
        detailReviewDto.setCrowded(review.isBright());
        detailReviewDto.setContent(review.getContent());
        detailReviewDto.setReviewImage(review.getReviewImage());

        return detailReviewDto;
    }

    public void createReview(HttpServletRequest request,
                             CreateReviewDto createReviewDto,
                             MultipartFile reviewImage) throws IOException {
        log.info("서비스 진입 : {}", createReviewDto);
        log.info("멀티파트 확인 : {}", reviewImage);

        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User>optionalUser = userRepository.findById(userId);
        if (!optionalUser.isPresent()) {
            log.error("존재하지 않는 유저 입니다.", userId);
            throw new NoUserException();
        }

        log.info("requestDto 전달 받음 : {}", createReviewDto.getContent());

        String fileType = "review";
        String reviewImageURL = s3Upload.uploadFile(userId, fileType, reviewImage);

        User user = optionalUser.get();
        Review review = new Review();
        review.setUser(user);
        review.setLongitude(createReviewDto.getLongitude());
        review.setLatitude(createReviewDto.getLatitude());
        review.setAddress(createReviewDto.getAddress());
        review.setScore(createReviewDto.getScore());
        review.setBright(createReviewDto.isBright());
        review.setCrowded(createReviewDto.isCrowded());
        review.setContent(createReviewDto.getContent());
        review.setReviewImage(reviewImageURL);
        reviewRepository.save(review);

        saveReviewtoReids(review.getReviewId(), review.getLongitude(), review.getLatitude(), review.getScore(), review.getAddress());
    }

    @Transactional
    public void deleteReview(HttpServletRequest request, long reviewId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> optionalUser = userRepository.findById(userId);
        if (!optionalUser.isPresent()) {
            log.error("존재하지 않는 유저 입니다.", userId);
            throw new NoUserException();
        }
        Optional<Review> optionalReview = reviewRepository.findById(reviewId);
        if (!optionalReview.isPresent()){
            log.error("존재하지 않는 리뷰 입니다.", reviewId);
            throw new NoReviewException();
        }
        Review review = optionalReview.get();
        String imageUrl = review.getReviewImage();
        s3Upload.deleteFile(imageUrl);
        reviewRepository.delete(review);

        deleteReviewFromRedis(reviewId, review.getScore(), review.getAddress());
    }

    private void saveReviewtoReids(long reviewId, double longitude, double latitude, int score, String address) {
        String key = "review";
        String member = reviewId + "_" + address + "_" + score;

        try {
            GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
            geoOperations.add(key, new Point(longitude, latitude), member);
            log.info("저장성공 : {}", member);
        } catch (Exception e) {
            log.error("저장실패 : {}", e.getMessage());
        }
    }

    private void deleteReviewFromRedis(long reviewId, int score, String address) {
        String key = "review";
        String member = reviewId + "_" + address + "_" + score;

        try {
            GeoOperations<String, Object> geoOperations = redisTemplate.opsForGeo();
            geoOperations.remove(key, member);
            log.info("삭제 성공 : {]", reviewId);
        } catch (Exception e) {
            log.error("삭제 실패 : {]", e.getMessage());
        }
    }
}
