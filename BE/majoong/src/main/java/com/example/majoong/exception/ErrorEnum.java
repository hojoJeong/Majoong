package com.example.majoong.exception;

public enum ErrorEnum {
    DUPLICATE_USER("실패", "중복된 회원입니다.", 600);


    private String flag;
    private String message;
    private int status;

    ErrorEnum(String flag, String message, int status) {
        this.flag = flag;
        this.message = message;
        this.status = status;
    }
}
