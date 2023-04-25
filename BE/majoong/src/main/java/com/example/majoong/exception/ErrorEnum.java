package com.example.majoong.exception;

public enum ErrorEnum {
    DUPLICATE_USER("중복된 회원입니다.", 600),
    NO_USER("갸입된 회원이 아닙니다.", 600);

    public String message;
    public int status;


    ErrorEnum(String message, int status) {
        this.message = message;
        this.status = status;
    }
}
