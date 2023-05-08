package com.example.majoong.tools;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.example.majoong.exception.NoFileException;
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
        if (multipartFile == null) {
            log.error("파일이 비었습니다.", multipartFile);
            throw new NoFileException();
        }

        String originalFilename = multipartFile.getOriginalFilename();
        String fileExtension = originalFilename.substring(originalFilename.lastIndexOf('.') + 1);
        String keyName = userId + "-" + fileType + "-" + System.currentTimeMillis() + "." + fileExtension; // 3-profile-1698273.jpg

        ObjectMetadata objMeta = new ObjectMetadata();
        objMeta.setContentLength(multipartFile.getInputStream().available());

        amazonS3Client.putObject(bucket, keyName, multipartFile.getInputStream(), objMeta);
        return amazonS3Client.getUrl(bucket, keyName).toString();
    }

    @Override
    public void deleteFile(String imageUrl) {
        try {
            String keyName = imageUrl.substring(imageUrl.lastIndexOf("/") + 1);
            amazonS3Client.deleteObject(bucket, keyName);
            log.info("s3삭제 성공, fileName : ", imageUrl);
        } catch (Exception e) {
            log.error("s3삭제 실패", e.getMessage());
        }
    }
}