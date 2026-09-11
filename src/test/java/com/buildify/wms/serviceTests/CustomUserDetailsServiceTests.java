package com.buildify.wms.serviceTests;

import com.wareflow.buildify.domain.auth.login.security.CustomUserDetailsService;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = {
        "file:src/main/webapp/WEB-INF/root-context.xml"
})
@MapperScan(basePackages = "com.wareflow.buildify.domain.auth.login.mapper")
@Log4j2
public class CustomUserDetailsServiceTests {

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Test
    @Transactional
    public void testLoadUserByUsername() {
        String testId = "admin01"; // 실제 존재하는 auth id
        UserDetails userDetails = userDetailsService.loadUserByUsername(testId);

        log.info("✅ 사용자 ID: {}", userDetails.getUsername());
        log.info("✅ 비밀번호(암호화): {}", userDetails.getPassword());
        log.info("✅ 권한 목록: {}", userDetails.getAuthorities());
    }
}
