package com.example.majoong.interceptor;

import com.example.majoong.tools.JwtTool;
import io.jsonwebtoken.JwtException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Slf4j
@Component
@RequiredArgsConstructor
public class UserInterceptor implements HandlerInterceptor {

    private final JwtTool jwtTool;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws JwtException {
        if (request.getHeader("Authorization")==null){
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return false;
        }
        String token = request.getHeader("Authorization").split(" ")[1];
        //accessToken 만료
        if( token == null || !jwtTool.validateToken(token)){
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return false;
        }
        return true;
    }
}
