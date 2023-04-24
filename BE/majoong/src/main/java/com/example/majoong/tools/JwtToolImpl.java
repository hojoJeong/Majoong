package com.example.majoong.tools;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

import java.io.UnsupportedEncodingException;
import java.util.Date;

public class JwtToolImpl implements JwtTool {
    private final String SECRET_KEY = "akwnd";

    @Override
    public String createAccessToken(int id) {
        Claims claims = Jwts.claims();
        claims.put("id", id);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 2)) //2시간
                .signWith(SignatureAlgorithm.HS256, this.generateKey())
                .compact();
    }
    @Override
    public String createRefreshToken(int id) {
        Claims claims = Jwts.claims();
        claims.put("id", id);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 48)) //48시간
                .signWith(SignatureAlgorithm.HS256, this.generateKey())
                .compact();
    }

    @Override
    public boolean validateToken(String token) {
        try {
            Jwts
                    .parser()
                    .setSigningKey(this.generateKey())
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
        }
        return false;
    }
    @Override
    public byte[] generateKey() {
        byte[] key = null;
        try {
            // charset 설정 안하면 사용자 플랫폼의 기본 인코딩 설정으로 인코딩 됨.
            key = SECRET_KEY.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {

        }
        return key;
    }

}
