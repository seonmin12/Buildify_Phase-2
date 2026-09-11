package com.buildify.wms.mapperTests;

import com.wareflow.buildify.domain.admin.inbound.mapper.AdminInboundMapper;
import com.wareflow.buildify.domain.user.inbound.mapper.UserInboundMapper;
import com.wareflow.buildify.dto.InboundApproveDTO;
import com.wareflow.buildify.dto.ProductDTO;
import com.wareflow.buildify.vo.InboundVO;
import com.wareflow.buildify.vo.ProductVO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
@Transactional
@Rollback

public class InboundMapperTests {
    @Autowired
    private AdminInboundMapper adminInboundMapper;

    @Autowired
    private UserInboundMapper userInboundMapper;

    @Test
    @Transactional
    public void testInboundList() {
        // given
        ProductVO clientId = new ProductVO();
        clientId.setClientId("CLI-20240301-0001"); // 여기에 실제 존재하는 clientId 넣기

        List<ProductVO> productList = userInboundMapper.inboundList(clientId);
        // then
        for (ProductVO product : productList) {
            log.info(product);
        }


    }

    @Test
    @Transactional
    public void testinboundInsertlist() {
        ProductVO clientId = new ProductVO();
        clientId.setClientId("CLI-20240301-0001"); // 여기에 실제 존재하는 clientId 넣기

        List<ProductVO> productList = userInboundMapper.inboundList(clientId);
        // then
        for (ProductVO product : productList) {
            log.info(product);
        }
    }

    @Test
    @Transactional
    public void testgetInboundInsert() {
        // given
        String prodId = "PRD-0001"; // 실제 존재하는 prodId 넣기

        List<String> prodIds = new ArrayList<>();
        prodIds.add(prodId);
        List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

        // then
        for (ProductDTO product : productList) {
            log.info(product);
        }
    }

        @Test
        @Transactional
        public void testinsertware () {
            // given
            String prodId = "CLI-20240301-0001"; // 실제 존재하는 prodId 넣기

            List<String> prodIds = new ArrayList<>();
            prodIds.add(prodId);
            List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

            // then
            for (ProductDTO product : productList) {
                log.info(product);
            }


        }

    @Test
    @Transactional
    public void updateInboundStatus () {
        // given
        String prodId = "INB-20250428-03167E59"; // 실제 존재하는 prodId 넣기

        List<String> prodIds = new ArrayList<>();
        prodIds.add(prodId);
        List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

        // then
        for (ProductDTO product : productList) {
            log.info(product);
        }
    }

    @Test
    @Transactional
    public void updateInventoryQuantity () {
        // given
        String prodId = "INB-20250428-03167E59"; // 실제 존재하는 prodId 넣기

        List<String> prodIds = new ArrayList<>();
        prodIds.add(prodId);
        List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

        // then
        for (ProductDTO product : productList) {
            log.info(product);
        }
    }

    @Test
    @Transactional
    public void insertInventoryIfNotExists () {
        // given
        String prodId = "INB-20250428-03167E59"; // 실제 존재하는 prodId 넣기

        List<String> prodIds = new ArrayList<>();
        prodIds.add(prodId);
        List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

        // then
        for (ProductDTO product : productList) {
            log.info(product);
        }
    }

    @Test
    @Transactional
    public void updateUserWarehouseUsage () {
        // given
        String prodId = "INB-20250428-03167E59"; // 실제 존재하는 prodId 넣기

        List<String> prodIds = new ArrayList<>();
        prodIds.add(prodId);
        List<ProductDTO> productList = userInboundMapper.getInboundInsert(prodIds);

        // then
        for (ProductDTO product : productList) {
            log.info(product);
        }
    }


    }

