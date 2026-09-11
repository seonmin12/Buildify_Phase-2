
package com.buildify.wms.serviceTests;


import com.wareflow.buildify.domain.admin.inventory.service.InventoryAdminService;
import com.wareflow.buildify.domain.auth.login.security.CustomUserDetails;
import com.wareflow.buildify.domain.user.inventory.service.InventoryUserService;
import com.wareflow.buildify.dto.InventoryAdminDTO;
import com.wareflow.buildify.dto.InventoryDTO;
import com.wareflow.buildify.dto.InventoryFilterDTO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(SpringExtension.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/root-context.xml")
@Log4j2
public class InventoryServiceTests {
    @Autowired(required = false)
    InventoryUserService inventoryUserService;

    @Autowired(required = false)
    InventoryAdminService inventoryAdminService;

    @BeforeEach
    public void setUpSecurityContext(){
        // 가짜 사용자 생성
        CustomUserDetails customUserDetails = new CustomUserDetails();
        customUserDetails.setClientId("CLI-20240301-0001");
        customUserDetails.setRole("0");

        // 인증 객체 만들기
        Authentication auth = new UsernamePasswordAuthenticationToken(customUserDetails, null, customUserDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);


    }

    @Test
    @Transactional
    @DisplayName("회원 본인 재고 조회 서비스 테스트 코드")
    public void testInventoryUserService() {
        // when
        List<InventoryDTO> list = inventoryUserService.getUserInventory();

        // then
        assertNotNull(list, "결과 리스트가 null이 아니어야 합니다");
        assertFalse(list.isEmpty(), "로그인한 회원의 재고가 하나 이상 있어야 합니다");

        // 반환된 모든 DTO의 clientId가 'CLT-001-AAA' 인지 검사
        list.forEach(dto ->
                assertEquals("CLI-20240301-0001", dto.getClientId(),
                        "반환된 DTO의 clientId가 로그인한 회원과 일치해야 합니다")
        );
    }

//    @Test
//    @DisplayName("회원 검색 서비스 테스트 코드")
//    public void testInventoryServiceUserSearch(){
//        // given
//        InventoryFilterDTO filter = new InventoryFilterDTO();
//
//        // 테스트 SQL 스크립트에 맞춰 값을 세팅
//        filter.setClientId("CLI-20240301-0001");
//        filter.setCategory1("PC");
//        filter.setCategory2("CPU");
//        filter.setCategory3("intel");
//
//        // when
//        List<InventoryDTO> results = inventoryUserService.searchUserInventory(filter);
//
//        // then
//        assertNotNull(results,    "결과 리스트가 null이면 안 됩니다");
//        assertFalse(results.isEmpty(), "적어도 한 건 이상의 결과가 있어야 합니다");
//
//    }

    @Test
    @DisplayName("관리자 조회 서비스 테스트 코드")
    public void testInventoryAdminService(){
        inventoryAdminService.getAdminInventory();

    }

    @Test
    @Transactional
    @DisplayName("관리자 재고 수량 수정 테스트 코드")
    public void testInventoryUpdate(){
        String inventoryId = "INV-0001";

        // 1) 초기 수량 조회
        List<InventoryAdminDTO> beforeList = inventoryAdminService.getAdminInventory();
        InventoryAdminDTO beforeDto = beforeList.stream()
                .filter(i -> inventoryId.equals(i.getInventoryId()))
                .findFirst()
                .orElseThrow();
        int beforeQty = beforeDto.getQuantity();

        // 2) 서비스 호출 (수량 +5)
        boolean result = inventoryAdminService.updateQuantity(inventoryId, beforeQty + 5);
        assertThat(result)
                .as("updateQuantity는 true를 반환해야 합니다")
                .isTrue();

        // 3) 변경 후 다시 조회
        List<InventoryAdminDTO> afterList = inventoryAdminService.getAdminInventory();
        InventoryAdminDTO afterDto = afterList.stream()
                .filter(i -> inventoryId.equals(i.getInventoryId()))
                .findFirst()
                .orElseThrow(() -> new AssertionError("INV001이 없어야 합니다."));
        int afterQty = afterDto.getQuantity();

        assertThat(afterQty)
                .as("수량이 %d에서 %d로 변경돼야 합니다", beforeQty, beforeQty + 5)
                .isEqualTo(beforeQty + 5);

    }

    @Test
    @Transactional
    @DisplayName("관리자 재고 삭제 테스트 코드")
    public void testDeleteInventories() {
        // 1) 삭제 전: 전체 리스트 조회
        List<InventoryAdminDTO> before = inventoryAdminService.getAdminInventory();
        assertThat(before)
                .as("테스트를 위해 재고가 최소 2개 이상 있어야 합니다")
                .hasSizeGreaterThanOrEqualTo(2);

        // 2) 지울 ID 두 개 선택
        String id1 = before.get(0).getInventoryId();
        String id2 = before.get(1).getInventoryId();
        log.info("▶ 삭제 대상 IDs: {}, {}", id1, id2);

        // 3) 서비스 호출
        int deletedCount = inventoryAdminService.deleteInventory(Arrays.asList(id1, id2));
        assertThat(deletedCount)
                .as("삭제된 건수는 요청한 ID 수(%d)와 같아야 합니다", 2)
                .isEqualTo(2);

        // 4) 삭제 후: 동일 ID들이 목록에서 사라졌는지 확인
        List<InventoryAdminDTO> after = inventoryAdminService.getAdminInventory();
        List<String> remainingIds = after.stream()
                .map(InventoryAdminDTO::getInventoryId)
                .collect(Collectors.toList());
        assertThat(remainingIds)
                .as("삭제된 ID들은 이제 목록에 없어야 합니다")
                .doesNotContain(id1, id2);

        // 5) 이미 삭제된 ID를 한 번 더 삭제 요청하면 0 리턴
        int deletedAgain = inventoryAdminService.deleteInventory(Arrays.asList(id1, id2));
        assertThat(deletedAgain)
                .as("이미 삭제된 항목을 재요청하면 0 반환")
                .isEqualTo(0);
    }

}

