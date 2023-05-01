package com.example.majoong.review.service;

import com.example.majoong.exception.NoReviewException;
import com.example.majoong.exception.NoUserException;
import com.example.majoong.review.domain.Review;
import com.example.majoong.review.dto.CreateReviewDto;
import com.example.majoong.review.dto.DetailReviewDto;
import com.example.majoong.review.repository.ReviewRepository;
import com.example.majoong.tools.JwtTool;
import com.example.majoong.user.domain.User;
import com.example.majoong.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewService {

    private UserRepository userRepository;
    private ReviewRepository reviewRepository;
    private final JwtTool jwtTool;

    public DetailReviewDto getDetailReview(HttpServletRequest request, int reviewId) {
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> optionalUser = userRepository.findById(userId);
        if (!optionalUser.isPresent()) {
            throw new NoUserException();
        }
        Optional<Review> optionalReview = reviewRepository.findById(reviewId);
        if (!optionalReview.isPresent()) {
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
        String token = request.getHeader("Authorization").split(" ")[1];
        int userId = jwtTool.getUserIdFromToken(token);

        Optional<User> optionalUser = userRepository.findById(userId);
        if (!optionalUser.isPresent()) {
            throw new NoUserException();
        }

        String fileName = String.valueOf(userId) + "review" + String.valueOf(System.currentTimeMillis());
//        String reviewImageURL = s3Service.upload(reviewImage, fileName);
        String reviewImageURL = "";

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
    }
}
