package com.wareflow.buildify.config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.io.InputStream;
import java.util.Properties;

// 카카오 지도 api 키 외부 파일 주입
public class SecretPropertiesLoader implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("application-secret.properties")) {
            Properties props = new Properties();
            props.load(input);
            String restKey = props.getProperty("kakao.rest.key");
            String jsKey = props.getProperty("kakao.javascript.key");
            sce.getServletContext().setAttribute("kakaoRestKey", restKey);
            sce.getServletContext().setAttribute("kakaoJavascriptKey", jsKey);
            // 키 값 자체는 로그에 남기지 않고 주입 여부만 확인합니다.
            System.out.println("🔑 Kakao REST API Key loaded = " + (restKey != null && !restKey.isEmpty()));
            System.out.println("🌐 Kakao JavaScript Key loaded = " + (jsKey != null && !jsKey.isEmpty()));

        } catch (Exception e) {
            throw new RuntimeException("Failed to load kakaoApiKey from application-secret.properties", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 종료 시 처리 없음
    }
}