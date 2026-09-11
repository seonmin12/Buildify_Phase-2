package com.buildify.wms.mapperTests;

import com.wareflow.buildify.domain.admin.inbound.mapper.AdminInboundMapper;
import com.wareflow.buildify.domain.admin.outbound.mapper.AdminOutboundMapper;
import com.wareflow.buildify.domain.user.outbound.mapper.UserOutboundMapper;
import com.wareflow.buildify.dto.AdminOutboundRequestDTO;
import com.wareflow.buildify.dto.InventoryDTO;
import com.wareflow.buildify.dto.OutboundDTO;
import com.wareflow.buildify.dto.ProductDTO;
import com.wareflow.buildify.vo.InboundVO;
import com.wareflow.buildify.vo.InventoryVO;
import com.wareflow.buildify.vo.OutboundVO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.ArrayList;
import java.util.List;

import static java.awt.AWTEventMulticaster.add;
import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = {
        "file:src/main/webapp/WEB-INF/root-context.xml"
})
@MapperScan(basePackages = "com.wareflow.buildify.domain.user.outbound.mapper")
@Log4j2
public class OutboundMapperTests {

    @Autowired
    private UserOutboundMapper userOutboundMapper;

    @Autowired
    private AdminOutboundMapper adminOutboundMapper;

    @Test
    public void userountboundList(){
        List<OutboundVO> vo = userOutboundMapper.outboundlist("CLI-20240301-0001");
        log.info("xptmxmpx");
        log.info(vo.size());
        for (int i = 0; i < vo.size(); i++) {
            log.info("테스트!!!! {}");
        }
    }

    @Test
    @DisplayName("UserOutboundMapper - 다건 상품 조회 테스트")
    public void testOutboundList() {
        // given

        String clientId = "CLI-20240301-0001"; // outboundlist 는 client_id 로 조회한다

        // when
        List<OutboundVO> productList = userOutboundMapper.outboundlist(clientId);

        // then
        assertThat(productList).isNotNull();
        assertThat(productList.size()).isGreaterThan(0);

        for (OutboundVO product : productList) {
            log.info("조회된 상품: {}", product);
        }
    }

//    @Test
//    public void updateInventory() {
//        // given
//        AdminOutboundRequestDTO dto = new AdminOutboundRequestDTO();
//        dto.setProdId("PRD-250428-0F1R4H");
//
//        // when
//        int result = adminOutboundMapper.updateInventory(dto);
//
//        // then
//        assertThat(result).isGreaterThan(0); // 업데이트가 1개 이상 됐는지 확인
//        log.info("업데이트 결과: {}", result);
//
//    }
//    @Test
//    public void updateOutbound() {
//        // given
//        AdminOutboundRequestDTO dto = new AdminOutboundRequestDTO();
//        dto.setProdId("PRD-250428-0F1R4H");
//
//        // when
//        int result = adminOutboundMapper.updateOutbound(dto);
//
//        // then
//        assertThat(result).isGreaterThan(0); // 업데이트가 1개 이상 됐는지 확인
//        log.info("업데이트 결과: {}", result);
//    }

//    @Test
//    public void updateUserWarehouse() {
//        // given
//        AdminOutboundRequestDTO dto = new AdminOutboundRequestDTO();
//        dto.setProdId("PRD-250428-0F1R4H");
//
//        // when
//        int result = adminOutboundMapper.updateUserWarehouse(dto);
//
//        // then
//        assertThat(result).isGreaterThan(0); // 업데이트가 1개 이상 됐는지 확인
//        log.info("업데이트 결과: {}", result);
//    }





}

