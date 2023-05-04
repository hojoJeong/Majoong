package com.example.majoong.response;

import com.example.majoong.exception.ErrorEnum;
import lombok.Data;
import lombok.ToString;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@Data
public class ResponseData {

    private int status;
    private String message;
    private Object data;

    public ResponseData() {
        this.status = 200;
        this.data = null;
        this.message = "성공";
    }

    public ResponseData(ErrorEnum error) {
        this.status = error.status;
        this.message = error.message;
    }

    public ResponseEntity<?> builder(){
        return new ResponseEntity<ResponseData>(this, HttpStatus.OK);
    }

}
