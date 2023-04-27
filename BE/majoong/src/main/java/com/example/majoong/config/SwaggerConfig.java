package com.example.majoong.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        Info info = new Info()
                .title("마중 API")
                .version("v1.0.0")
                .description("마중 프로젝트 API 명세서입니다.");
        return new OpenAPI()
                .components(new Components())
                .info(info);
    }
}

