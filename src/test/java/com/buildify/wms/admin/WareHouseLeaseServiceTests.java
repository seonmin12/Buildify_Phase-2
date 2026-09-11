package com.buildify.wms.admin;

import com.wareflow.buildify.domain.admin.systemOperation.mapper.AdminWarehouseLeaseMapper;
import com.wareflow.buildify.domain.admin.systemOperation.service.AdminWarehouseLeaseService;
import com.wareflow.buildify.dto.UserDTO;
import com.wareflow.buildify.dto.WarehouseLeaseDTO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
public class WareHouseLeaseServiceTests {

    @Autowired
    AdminWarehouseLeaseService adminWarehouseLeaseService;
    
    @Autowired
    AdminWarehouseLeaseMapper adminWarehouseLeaseMapper;

    @Test
    @Transactional
    @DisplayName("회원 계약관리 서비스 테스트")
    public void leaseServiceTest(){

        Long start = System.currentTimeMillis();
        List<WarehouseLeaseDTO> warehouseLeaseDTOList = adminWarehouseLeaseService.getUserLeaseInfo();
        Long end = System.currentTimeMillis();
        log.info("서비스 리스트 사이즈 : "+warehouseLeaseDTOList.size());
        log.info("실행시간 : {} ms",(end-start));
    }

    @Test
    @Transactional
    @DisplayName("DB vs 싱글톤 캐시 속도 테스트")
    public void speedTest(){

        int rows = 0;
        log.info("더미 데이터 삽입 수 : {}",rows);

        for (int i = 0; i < 100; i++) {
            UserDTO userDTO = new UserDTO();
            userDTO.setClientId("cleintid-"+i);
            userDTO.setUserName("name-"+i);
            userDTO.setBusinessNumber("businessNumber-"+i);
            userDTO.setUserPhone("010-1234-"+i);
            userDTO.setUserEmail("email@"+i);
            userDTO.setUserAddress("주소-"+i);
            userDTO.setUserId("id-"+i);
            userDTO.setUserPw("pw-"+i);
            userDTO.setUserStatus(0);
            adminWarehouseLeaseMapper.insertDummyUser(userDTO);
            rows++;
        }

        log.info("더미 데이터 삽입 수 : {}",rows);

        for (int i = 1; i <= 10; i++) {
            Long start = System.nanoTime();
            List<WarehouseLeaseDTO> warehouseLeaseDTOList = adminWarehouseLeaseService.getUserLeaseDbInfo();
            Long end = System.nanoTime();
            log.info("DB Test {}회차 실행시간 : {} ", i, (end-start));
        }

        for (int i = 1; i <= 10; i++) {
            Long start = System.nanoTime();
            List<WarehouseLeaseDTO> warehouseLeaseDTOList = adminWarehouseLeaseService.getUserLeaseInfo();
            Long end = System.nanoTime();
            log.info("싱글톤 캐시 Test {}회차 실행시간 : {} ", i, (end-start));
        }

    }

    @Test
    @DisplayName("회원 계약 정보 수정 테스트")
    @Transactional
    public void leaseModifyService(){
        List<WarehouseLeaseDTO> warehouseLeaseDTOList = new ArrayList<>();

        WarehouseLeaseDTO userWareHouseDTO = WarehouseLeaseDTO.builder()
                .wareId("WH01")
                .wareCoord("A1")
                .clientId("CLI-20240301-0001")
                .endDate(LocalDate.now())
                .build();
        warehouseLeaseDTOList.add(userWareHouseDTO);

        WarehouseLeaseDTO userWareHouseDTO2 = WarehouseLeaseDTO.builder()
                .wareId("WH02")
                .wareCoord("B2")
                .clientId("CLI-20240301-0002")
                .endDate(LocalDate.now())
                .build();
        warehouseLeaseDTOList.add(userWareHouseDTO2);

        List<String> clientIds = warehouseLeaseDTOList.stream().map(WarehouseLeaseDTO::getClientId).toList();
        List<String> endDates = warehouseLeaseDTOList.stream().map(dto -> dto.getEndDate().toString()).toList();
        List<String> wareIds = warehouseLeaseDTOList.stream().map(WarehouseLeaseDTO::getWareId).toList();
        List<String> wareCoords = warehouseLeaseDTOList.stream().map(WarehouseLeaseDTO::getWareCoord).toList();
        int rows = adminWarehouseLeaseService.modifyLeaseRequests(clientIds, endDates, wareIds, wareCoords);
        log.info("변경 완료 : {}",rows);
    }

}
