package com.example.majoong.tools;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface S3Upload {

    String uploadFile(int userId, String fileType, MultipartFile multipartFile) throws IOException;

    String deleteFile(String fileName);
}
