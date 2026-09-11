package com.buildify.wms.admin;

import com.wareflow.buildify.domain.admin.systemOperation.mapper.AdminWarehouseLeaseMapper;
import com.wareflow.buildify.dto.WarehouseLeaseDTO;
import com.wareflow.buildify.vo.UserWareHouseVO;
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

import static org.assertj.core.util.DateUtil.now;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
public class WareHouseLeaseMapperTests {

    @Autowired
    AdminWarehouseLeaseMapper adminWarehouseLeaseMapper;

    @Test
    @Transactional
    @DisplayName("계약 정보 불러오기")
    public void wareLeaseTest(){
        log.info("테스트 시작");
        List<WarehouseLeaseDTO> warehouseLeaseDTOList = adminWarehouseLeaseMapper.getUserLeaseInfo();
        log.info("계약 건수 : " + warehouseLeaseDTOList.size());
        log.info("계약 리스트 출력");
        for (WarehouseLeaseDTO warehouseLeaseDTO : warehouseLeaseDTOList){
            log.info(warehouseLeaseDTO);
        }

    }

    @Test
    @DisplayName("계약 정보 수정")
    @Transactional
    public void wareLeaseModifyTest(){


        List<UserWareHouseVO> userWareHouseVOList = new ArrayList<>();

        UserWareHouseVO userWareHouseVO = UserWareHouseVO.builder()
                .wareId("WH01")
                .warehousePosX("A")
                .warehousePosY(1)
                .clientId("CLI-20240301-0001")
                .wareEndDate(LocalDate.now())
                .build();
        userWareHouseVOList.add(userWareHouseVO);

        UserWareHouseVO userWareHouseVO2 = UserWareHouseVO.builder()
                .wareId("WH02")
                .warehousePosX("B")
                .warehousePosY(2)
                .clientId("CLI-20240301-0002")
                .wareEndDate(LocalDate.now())
                .build();
        userWareHouseVOList.add(userWareHouseVO2);

        int rows = adminWarehouseLeaseMapper.modifyUserLeaseInfo(userWareHouseVOList);

//        int rows = 0;
//        for (UserWareHouseVO userWareHouse : userWareHouseVOList){
//            rows += adminWarehouseLeaseMapper.modifyUserLeaseInfo(userWareHouse);
//            log.info(userWareHouse.getWareEndDate());
//        }
//        int rows = adminWarehouseLeaseMapper.modifyUserLeaseInfo(userWareHouseVO);

        log.info("변경 성공 : {}",rows);


    }
}
