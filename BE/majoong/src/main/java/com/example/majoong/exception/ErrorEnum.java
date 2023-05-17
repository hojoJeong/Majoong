package com.example.majoong.exception;

public enum ErrorEnum {
    NOT_EXIST_SESSION_FOR_CONNECTION("세션이 존재하지 않아 연결을 삭제할 수 없습니다.",400),
    INVALID_REFRESHTOKEN("refreshToken 만료", 401),
    INSUFFICIENT_PERMISSION("권한이 없습니다.",403),
    NOT_EXIST_CONNECTION("해당 연결이 존재하지 않습니다.",404),
    NOT_EXIST_SESSION("해당 세션이 존재하지 않습니다.",404),
    NOT_EXIST_RECORDING("해당 녹화 영상은 존재하지 않습니다.", 404),
    NO_CONNECTED_PARTICIPANTS("녹화 시작 실패: 세션에 연결된 참가자가 없습니다.",406),
    RECORDING_NOT_STARTED("녹화를 중단할 수 없습니다. 잠시 후 다시 시도해주세요.",406),
    RECORDING_IN_PROGRESS("녹화가 진행중입니다.", 409),
    DUPLICATE_PHONENUMBER("이미 가입된 휴대폰번호입니다.", 600),
    DUPLICATE_SOCIAL_PK("중복된 social PK 입니다.",600),
    NO_USER("가입된 회원이 아닙니다.", 601),
    DELETED_USER("탈퇴한 계정입니다.", 602),
    EXIST_FRIEND("이미 친구입니다.", 603),
    EXIST_FRIEND_REQUEST("이미 친구요청을 보낸 상태입니다.", 603),
    NOT_EXIST_FRIEND_REQUEST("해당 친구요청이 없습니다.", 604),
    NOT_FRIEND("친구가 아닙니다.", 605),
    WRONG_NUMBER("인증번호가 틀립니다.", 700),
    EXPIRED_NUMBER("인증번호 유효기간 만료", 701),
    NOT_EXIST_FCM_TOKEN("fcm 토큰이 존재하지 않습니다.",404),
    NO_FILE("파일이 존재하지 않습니다.", 404),
    NOT_EXIST_SHARE_LOCATION("위치공유 정보가 없습니다.",404),
    SAME_NODE("시작점과 도착점이 같습니다.", 404),
    EXCEED_DISTANCE("직선거리 30km를 초과했습니다.", 404);

    public String message;
    public int status;


    ErrorEnum(String message, int status) {
        this.message = message;
        this.status = status;
    }
}
