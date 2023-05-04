package com.example.majoong.exception;

public enum ErrorEnum {
    NOT_EXIST_SESSION_FOR_CONNECTION("세션이 존재하지 않아 연결을 삭제할 수 없습니다.",400),
    INVALID_REFRESHTOKEN("refreshToken 만료", 401),
    SESSION_DELETION_PERMISSION("세션 삭제 권한이 없습니다.",403),
    NOT_EXIST_CONNECTION("해당 연결이 존재하지 않습니다.",404),
    NOT_EXIST_SESSION("해당 세션이 존재하지 않습니다.",404),
    NOT_EXIST_RECORDING("해당 녹화 영상은 존재하지 않습니다.", 404),
    RECORDING_IN_PROGRESS("녹화가 진행중이므로 삭제할 수 없습니다.", 409),
    DUPLICATE_PHONENUMBER("이미 가입된 휴대폰번호입니다.", 600),
    DUPLICATE_SOCIAL_PK("중복된 social PK 입니다.",600),
    NO_USER("가입된 회원이 아닙니다.", 601),
    DELETED_USER("탈퇴한 계정입니다.", 602),
    EXIST_FRIEND("이미 친구입니다.", 603),
    EXIST_FRIEND_REQUEST("이미 친구요청을 보낸 상태입니다.", 603),
    NOT_EXIST_FRIEND_REQUEST("해당 친구요청이 없습니다.", 604),
    NOT_FRIEND("친구가 아닙니다.", 605),
    WRONG_NUMBER("인증번호가 틀립니다.", 700),
    EXPIRED_NUMBER("인증번호 유효기간 만료", 701);


    public String message;
    public int status;


    ErrorEnum(String message, int status) {
        this.message = message;
        this.status = status;
    }
}
