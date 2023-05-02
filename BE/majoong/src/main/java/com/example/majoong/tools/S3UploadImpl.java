package com.example.majoong.tools;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
@Service
public class S3UploadImpl implements S3Upload{

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;
    @Autowired
    AmazonS3Client amazonS3Client;

    @Override
    public String uploadFile(int userId, String fileType, MultipartFile multipartFile) throws IOException {
        String s3FileName = userId + "-" + fileType + "-" + System.currentTimeMillis(); // 3-profile-1698273

        ObjectMetadata objMeta = new ObjectMetadata();
        objMeta.setContentLength(multipartFile.getInputStream().available());

        amazonS3Client.putObject(bucket, s3FileName, multipartFile.getInputStream(), objMeta);
        return amazonS3Client.getUrl(bucket, s3FileName).toString();
    }

    @Override
    public String deleteFile(String fileName) {
        return null;
    }
}
