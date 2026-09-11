
package com.buildify.wms.mapperTests;

import com.wareflow.buildify.domain.admin.inventory.mapper.InventoryAdminMapper;
import com.wareflow.buildify.domain.user.inventory.mapper.InventoryUserMapper;
import com.wareflow.buildify.dto.InventoryAdminDTO;
import com.wareflow.buildify.dto.InventoryDTO;
import com.wareflow.buildify.dto.InventoryFilterDTO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
@Transactional
@Rollback


public class InventoryMapperTests {

    @Autowired(required = false)
    InventoryUserMapper inventoryUserMapper;

    @Autowired(required = false)
    InventoryAdminMapper inventoryAdminMapper;


    @Test
    @Transactional
    @DisplayName("회원 조회 mapper 테스트 코드")
    public void testInventoryUserMapperList(){
        // given
        String testClientId = "CLI-20240301-0001";

        //when
        List<InventoryDTO> result = inventoryUserMapper.getUserInventory(testClientId);

        //then
        Assertions.assertNotNull(result);
        Assertions.assertFalse(result.isEmpty());

        // 출력 확인
        result.forEach(System.out::println);
    }



    @Test
    @Transactional
    @DisplayName("회원 검색 mapper 테스트 코드")
    public void testInventorySearch(){

        InventoryFilterDTO filter = new InventoryFilterDTO();
        filter.setCategory1("컴퓨터");
        filter.setSearchType("prodName");
        filter.setKeyword("i7-12700K");

        List<InventoryDTO> result = inventoryUserMapper.searchUserInventory(filter);

        assertThat(result).isNotNull();
        log.info("전체 조회 결과 수: {}" , result.size());
        for (InventoryDTO dto : result) {
            log.info("▶ 전체 조회 상품: {}", dto);
        }

    }

    @Test
    @DisplayName("회원 중분류 mapper 테스트 코드")
    public void testInventoryMapperUserMidCategory(){
        // given
        String clientId = "CLI-20240301-0001";
        String category1 = "건축자재";


        // when

        List<String>midCategories = inventoryUserMapper.findMidCategoriesByLevel1(clientId, category1);


        // then
        Assertions.assertNotNull(midCategories);
        Assertions.assertFalse(midCategories.isEmpty());
        midCategories.forEach(System.out::println);

    }

//    @Test
//    @DisplayName("회원 소분류 mapper 테스트 코드")
//    public void testInventoryMapperUserSmallCategory(){
//
//        // given
//        String clientId = "CLI-20240301-0001";
//        String category2 = "CPU";
//
//
//        // when
//
//        List<String>smallCategories = inventoryUserMapper.findSmallCategoriesByLevel2(clientId,category2);
//
//
//        // then
//        Assertions.assertNotNull(smallCategories);
//        Assertions.assertFalse(smallCategories.isEmpty());
//        smallCategories.forEach(System.out::println);
//    }

    @Test
    @Transactional
    @DisplayName("관리자 조회 테스트 코드")
    public void testGetAdminInventory(){

        List<InventoryAdminDTO> result = inventoryAdminMapper.getAdminInventory();
        log.info("전체 조회 결과 수: {} ", result.size());
        for (InventoryAdminDTO dto : result) {
            log.info("▶ 전체 조회 상품: {}", dto);
        }


    }

    @Test
    @Transactional
    @DisplayName("관리자 수량 업데이트 테스트 코드")
    public void testUpdateQuantity(){
        String inventoryId = "INV-0001";

        // 1) 초기값 조회
        List<InventoryAdminDTO> allBefore = inventoryAdminMapper.getAdminInventory();
        InventoryAdminDTO beforeDto = allBefore.stream()
                .filter(i -> inventoryId.equals(i.getInventoryId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("INV001이 존재해야 합니다."));
        int beforeQty = beforeDto.getQuantity();

        // 2) 수량 변경 (예: +5)
        int newQty = beforeQty + 5;
        int affected = inventoryAdminMapper.updateQuantity(inventoryId, newQty);
        assertThat(affected)
                .as("updateQuantity는 1행을 수정해야 합니다")
                .isEqualTo(1);

        // 3) 변경 후 다시 전체 조회해서 같은 ID의 수량만 추출
        List<InventoryAdminDTO> allAfter = inventoryAdminMapper.getAdminInventory();
        InventoryAdminDTO afterDto = allAfter.stream()
                .filter(i -> inventoryId.equals(i.getInventoryId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("INV001이 존재해야 합니다."));
        int afterQty = afterDto.getQuantity();

        assertThat(afterQty)
                .as("수량이 %d에서 %d로 바뀌어야 합니다", beforeQty, newQty)
                .isEqualTo(newQty);
    }



    @Test
    @Transactional
    @DisplayName("관리자 재고 삭제 테스트 코드")
    public void testDeleteInventory() {
        // 1) 사전 조회: 삭제할 ID를 하나 가져온다
        List<InventoryAdminDTO> before = inventoryAdminMapper.getAdminInventory();
        assertThat(before)
                .as("삭제 전 데이터가 있어야 한다")
                .isNotEmpty();

        String targetId = before.get(0).getInventoryId();
        log.info("▶ 삭제 대상 ID: {}", targetId);

        // 2) deleteInventory 호출
        int deletedCount = inventoryAdminMapper.deleteInventory(targetId);
        assertThat(deletedCount)
                .as("삭제된 행 수가 1이어야 한다")
                .isEqualTo(1);

        // 3) 삭제 후 조회: 동일 ID가 없어야 한다
        List<InventoryAdminDTO> after = inventoryAdminMapper.getAdminInventory();
        assertThat(after)
                .extracting(InventoryAdminDTO::getInventoryId)
                .as("삭제된 ID는 목록에 없어야 한다")
                .doesNotContain(targetId);

        // 4) 같은 ID를 한 번 더 삭제하려 하면 0을 반환해야 한다
        int deletedAgain = inventoryAdminMapper.deleteInventory(targetId);
        assertThat(deletedAgain)
                .as("이미 삭제된 항목을 다시 삭제하면 0이 반환되어야 한다")
                .isEqualTo(0);
    }

    }





