package com.example.majoong.exception;

import com.example.majoong.response.ResponseData;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ErrorHandler {
    @ExceptionHandler(DuplicatePhoneNumberException.class)
    public ResponseEntity<?> DuplicatePhoneNumberException() {
        ResponseData data = new ResponseData(ErrorEnum.DUPLICATE_PHONENUMBER);
        return data.builder();
    }
    @ExceptionHandler(NoUserException.class)
    public ResponseEntity<?> NoUserException() {
        ResponseData data = new ResponseData(ErrorEnum.NO_USER);
        return data.builder();
    }

    @ExceptionHandler(RefreshTokenException.class)
    public ResponseEntity<?> RefreshTokenException() {
        ResponseData data = new ResponseData(ErrorEnum.INVALID_REFRESHTOKEN);
        return data.builder();
    }

    @ExceptionHandler(WrongNumberException.class)
    public ResponseEntity<?> WrongNumberException() {
        ResponseData data = new ResponseData(ErrorEnum.WRONG_NUMBER);
        return data.builder();
    }

    @ExceptionHandler(ExpiredNumberException.class)
    public ResponseEntity<?> ExpiredNumberException() {
        ResponseData data = new ResponseData(ErrorEnum.EXPIRED_NUMBER);
        return data.builder();
    }

    @ExceptionHandler(DeletedUserException.class)
    public ResponseEntity<?> DeletedUserException() {
        ResponseData data = new ResponseData(ErrorEnum.DELETED_USER);
        return data.builder();
    }

    @ExceptionHandler(ExistFriendException.class)
    public ResponseEntity<?> ExistFriendException() {
        ResponseData data = new ResponseData(ErrorEnum.EXIST_FRIEND);
        return data.builder();
    }

    @ExceptionHandler(ExistFriendRequestException.class)
    public ResponseEntity<?> ExistFriendRequestException() {
        ResponseData data = new ResponseData(ErrorEnum.EXIST_FRIEND_REQUEST);
        return data.builder();
    }

    @ExceptionHandler(NotExistFriendRequestException.class)
    public ResponseEntity<?> NotExistFriendRequestException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_FRIEND_REQUEST);
        return data.builder();
    }

    @ExceptionHandler(NotFriendException.class)
    public ResponseEntity<?> NotFriendException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_FRIEND);
        return data.builder();
    }

}
