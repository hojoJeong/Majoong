package com.example.majoong.review.dto;

import lombok.Data;
import lombok.Setter;

@Data
public class DetailReviewDto {

    private int reviewId;
    private String address;
    private int score;
    private boolean isBright;
    private boolean isCrowded;
    private String content;
    private String reviewImage;
}