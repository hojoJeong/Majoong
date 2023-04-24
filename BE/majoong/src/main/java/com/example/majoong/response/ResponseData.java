package com.example.majoong.response;

import com.example.majoong.exception.ErrorEnum;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Data
public class ResponseData {

    private int status;

    private String flag;
    private String message;
    private Object data;

    public ResponseData() {
        this.flag = "success";
        this.status = 200;
        this.data = null;
        this.message =null;
    }

    public ResponseData(ErrorEnum error) {
        this.flag = error.flag;
        this.status = error.status;
        this.message = error.message;
    }

    public enum StatusEnum {
        OK(200, "OK"),
        BAD_REQUEST(400, "BAD_REQUEST"),
        NOT_FOUND(404, "NOT_FOUND"),
        INTERNAL_SERVER_ERROR(500, "INTERNAL_SERVER_ERROR"),
        DUPLICATE_DATA_ERROR(600,"DUPLICATE_DATA_ERROR");

        int statusCode;
        String code;

        StatusEnum(int statusCode, String code) {
            this.statusCode = statusCode;
            this.code = code;
        }
    }



    public ResponseEntity<?> builder(){
        return new ResponseEntity<ResponseData>(this, HttpStatus.OK);
    }

}
