package com.example.majoong.exception;

public enum ErrorEnum {
    DUPLICATE_USER("fail", "중복된 회원입니다.", 600);

    public String flag;
    public String message;
    public int status;


    ErrorEnum(String flag, String message, int status) {
        this.flag = flag;
        this.message = message;
        this.status = status;
    }
}
