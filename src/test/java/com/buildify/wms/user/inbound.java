package com.buildify.wms.user;

import com.wareflow.buildify.domain.user.inbound.mapper.UserInboundMapper;
import com.wareflow.buildify.domain.user.inbound.service.UserInboundService;
import com.wareflow.buildify.dto.ProductDTO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
public class inbound {

    @Autowired
    UserInboundMapper userInboundMapper;

    @Autowired
    UserInboundService userInboundService;

    @Test
    @Transactional
    public void testFindProductsByIds() {
        // given
        List<String> prodId = Arrays.asList("PRD-0001");

        // when
        List<ProductDTO> products = userInboundMapper.getInboundInsert(prodId);

        // then
        assertNotNull(products);
        assertFalse(products.isEmpty());
        products.forEach(product -> {
            System.out.println("상품 ID: " + product.getProdId());
            System.out.println("상품명: " + product.getProdName());
        });
    }

    @Test
    @Transactional
    public void test2(){
        // given
        List<String> prodIds = Arrays.asList("PRD-0001", "PRD-0002"); // 실제 존재하는 prod_id로 테스트할 것

        // when
        List<ProductDTO> result = userInboundService.getInboundInsert(prodIds);

        // then
        assertNotNull(result);
        assertFalse(result.isEmpty());
        result.forEach(p -> {
            System.out.println("✔ 상품 ID: " + p.getProdId());
            System.out.println("✔ 상품명: " + p.getProdName());
            System.out.println("✔ 가격: " + p.getProdPrice());
            System.out.println("✔ 사이즈: " + p.getProdSize());
        });
    }

}


