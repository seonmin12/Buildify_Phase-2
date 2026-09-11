package com.buildify.wms.serviceTests;

import com.wareflow.buildify.domain.user.product.service.ProductService;
import com.wareflow.buildify.dto.ProductDTO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import com.wareflow.buildify.domain.auth.login.security.CustomUserDetails;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = {
        "file:src/main/webapp/WEB-INF/root-context.xml"
})
@Log4j2
public class GetProductListTests {

    @Autowired
    private ProductService productService;

    // ProductService 는 SecurityContext 에서 로그인 회원을 읽으므로
    // 테스트에서도 인증 정보를 미리 넣어 주어야 한다.
    @BeforeEach
    public void setUpSecurityContext() {
        CustomUserDetails customUserDetails = new CustomUserDetails();
        customUserDetails.setClientId("CLI-20240301-0001");
        customUserDetails.setRole("0");

        Authentication auth = new UsernamePasswordAuthenticationToken(
                customUserDetails, null, customUserDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    public void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    @Transactional
    public void getProductList() {
       List<ProductDTO> productDTOList = productService.getProductList();
        log.info("productDTOList: {}", productDTOList);
    }

}
