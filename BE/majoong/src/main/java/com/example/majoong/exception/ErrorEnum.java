package com.example.majoong.exception;

public enum ErrorEnum {
    INVALID_REFRESHTOKEN("refreshToken 만료", 401),
    DUPLICATE_PHONENUMBER("이미 가입된 휴대폰번호입니다.", 600),
    NO_USER("가입된 회원이 아닙니다.", 601),
    WRONG_NUMBER("인증번호가 틀립니다.", 700),
    EXPIRED_NUMBER("인증번호 유효기간 만료", 701);

    public String message;
    public int status;


    ErrorEnum(String message, int status) {
        this.message = message;
        this.status = status;
    }
}
