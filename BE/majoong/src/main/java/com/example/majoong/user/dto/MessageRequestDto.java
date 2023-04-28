package com.example.majoong.user.dto;

import lombok.Builder;
import lombok.Data;

import java.net.SocketOption;
import java.util.List;

@Data
@Builder
public class MessageRequestDto {
    private String type;
    private String contentType;
    private String countryCode;
    private String from;
    private String content;
    private List<MessageDto> messages;


}
