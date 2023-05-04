package com.example.majoong.review.dto;

import lombok.Data;

@Data
public class CreateReviewDto {

    private double longitude;
    private double latitude;
    private String address;
    private int score;
    private boolean isBright;
    private boolean isCrowded;
    private String content;

    public CreateReviewDto(double longitude,
                           double latitude,
                           String address,
                           int score,
                           boolean isBright,
                           boolean isCrowded,
                           String content) {
        this.longitude = longitude;
        this.latitude = latitude;
        this.address = address;
        this.score = score;
        this.isBright = isBright;
        this.isCrowded = isCrowded;
        this.content = content;
    }
}
