package com.example.majoong.tools;

public interface JwtTool {

    String createAccessToken(int id);
    String createRefreshToken(int id);
    boolean validateToken(String token);
    byte[] generateKey();

}
