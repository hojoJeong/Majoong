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

    @ExceptionHandler(DuplicateSocialPKException.class)
    public ResponseEntity<?> DuplicateSocialPKException() {
        ResponseData data = new ResponseData(ErrorEnum.DUPLICATE_SOCIAL_PK);
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

    @ExceptionHandler(NotExistRecordingException.class)
    public ResponseEntity<?> NotExistRecordingException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_RECORDING);
        return data.builder();
    }

    @ExceptionHandler(RecordingInProgressException.class)
    public ResponseEntity<?> RecordingInProgressException() {
        ResponseData data = new ResponseData(ErrorEnum.RECORDING_IN_PROGRESS);
        return data.builder();
    }

    @ExceptionHandler(NotExistSessionException.class)
    public ResponseEntity<?> NotExistSessionException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_SESSION);
        return data.builder();
    }

    @ExceptionHandler(InsufficientPermissionException.class)
    public ResponseEntity<?> SessionDeletionPermissionException() {
        ResponseData data = new ResponseData(ErrorEnum.INSUFFICIENT_PERMISSION);
        return data.builder();
    }

    @ExceptionHandler(NotExistConnectionException.class)
    public ResponseEntity<?> NotExistConnectionException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_CONNECTION);
        return data.builder();
    }

    @ExceptionHandler(NotExistSessionForConnectionException.class)
    public ResponseEntity<?> NotExistSessionForConnectionException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_SESSION_FOR_CONNECTION);
        return data.builder();
    }


    @ExceptionHandler(NoConnectedParticipantsException.class)
    public ResponseEntity<?> NoConnectedParticipantsException() {
        ResponseData data = new ResponseData(ErrorEnum.NO_CONNECTED_PARTICIPANTS);
        return data.builder();
    }


    @ExceptionHandler(RecordingNotStartedException.class)
    public ResponseEntity<?> RecordingNotStartedException() {
        ResponseData data = new ResponseData(ErrorEnum.RECORDING_NOT_STARTED);
        return data.builder();
    }

    @ExceptionHandler(NoFileException.class)
    public ResponseEntity<?> NoFileException() {
        ResponseData data = new ResponseData(ErrorEnum.NO_USER);
        return data.builder();
    }

    @ExceptionHandler(NoFcmTokenException.class)
    public ResponseEntity<?> NoFcmTokenException() {
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_FCM_TOKEN);
        return data.builder();
    }

    @ExceptionHandler(NotExistShareLocationException.class)
    public ResponseEntity<?> NotExistShareLocationException(){
        ResponseData data = new ResponseData(ErrorEnum.NOT_EXIST_SHARE_LOCATION);
        return data.builder();
    }
}
