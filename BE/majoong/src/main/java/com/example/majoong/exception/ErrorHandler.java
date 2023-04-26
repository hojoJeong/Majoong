package com.example.majoong.exception;

import com.example.majoong.response.ResponseData;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class ErrorHandler {
    @ExceptionHandler(DuplicateUserException.class)
    public ResponseEntity<?> DuplicateUserException() {
        ResponseData data = new ResponseData(ErrorEnum.DUPLICATE_USER);
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
}
