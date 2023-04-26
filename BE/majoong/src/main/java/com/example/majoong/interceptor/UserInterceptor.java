package com.example.majoong.interceptor;

import com.example.majoong.tools.JwtTool;
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
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String token = request.getHeader("Authorization");
        //accessToken 만료
        if( token == null || !jwtTool.validateToken(token.split(" ")[1])) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,"JWT 만료");
            return false;
        }

        return true;
    }
}
