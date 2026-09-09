-- =====================================================================
-- BuildiFy WMS - 뷰 / 프로시저 / 트리거 (Docker 초기화 전용)
--
-- 원본: src/main/java/com/wareflow/buildify/mySql/*.sql
--   - AdminDashboardView.sql  : 그대로 사용
--   - InboundProcedure.sql    : 그대로 사용
--   - outbound.sql            : 프로시저 부분만 사용 (파일 뒷부분의 MyBatis XML 조각 제외)
--   - WareTrigger.sql         : 트리거만 사용 (끝의 SHOW TRIGGERS 제외)
--   - Inbound.sql             : 미완성 SQL 이라 제외 (아래 주석 참고)
--
-- 시드 데이터 적재(02-seed.sql) 이후에 실행되므로,
-- userWareHouse 트리거가 시드 INSERT 에 개입하지 않습니다.
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 1. 관리자 대시보드 뷰 (앱 기동 시 @PostConstruct 에서 조회하므로 필수)
-- ---------------------------------------------------------------------
# 관리자 대시보드 입고 현황 뷰
CREATE OR REPLACE VIEW v_inbound_stats AS
WITH RECURSIVE dates AS (
    SELECT CURDATE() - INTERVAL 365 DAY AS date
    UNION ALL
    SELECT date + INTERVAL 1 DAY
    FROM dates
    WHERE date + INTERVAL 1 DAY <= CURDATE()
)
SELECT
    d.date,
    COUNT(DISTINCT i.inbound_id) AS requestCount,
    COUNT(DISTINCT p.inbound_id) AS approvalCount
FROM dates d
         LEFT JOIN inbound i ON DATE(i.req_inbound_date) = d.date
         LEFT JOIN inbound p ON DATE(p.inbound_process_date) = d.date AND p.inbound_status = 1
GROUP BY d.date
ORDER BY d.date;

# 관리자 대시보드 출고 현황 뷰
CREATE OR REPLACE VIEW v_outbound_stats AS
WITH RECURSIVE dates AS (
    SELECT CURDATE() - INTERVAL 365 DAY AS date
    UNION ALL
    SELECT date + INTERVAL 1 DAY
    FROM dates
    WHERE date + INTERVAL 1 DAY <= CURDATE()
)
SELECT
    d.date,
    COUNT(DISTINCT o.outbound_id) AS requestCount,
    COUNT(DISTINCT p.outbound_id) AS approvalCount
FROM dates d
         LEFT JOIN outbound o ON DATE(o.req_outbound_date) = d.date
         LEFT JOIN outbound p ON DATE(p.outbound_process_date) = d.date AND p.status = 1
GROUP BY d.date
ORDER BY d.date;


# 창고별 계약률/가용률 view
CREATE OR REPLACE VIEW v_ware_dashboard AS
select area.ware_id,(count(user.ware_id)/25) as 계약률,(1-(area.available_space/area.ware_total_size)) as 가용률
from warehouse_area area
         left join userWareHouse user
              on user.ware_id = area.ware_id
group by area.ware_id;

-- ---------------------------------------------------------------------
-- 2. 입고 승인 프로시저
-- ---------------------------------------------------------------------
DROP PROCEDURE  IF EXISTS inbound_approve;

DELIMITER $$

CREATE PROCEDURE inbound_approve(
    IN in_inventory_id VARCHAR(20),
    IN in_client_id VARCHAR(20),
    IN in_ware_id VARCHAR(10),
    IN in_pos_x VARCHAR(10),
    IN in_pos_y INTEGER,
    IN in_prod_id VARCHAR(20),
    IN in_quantity INT,
    IN in_new_usage DECIMAL,
    IN in_inbound_id VARCHAR(30)
)
BEGIN
START TRANSACTION;
IF in_inventory_id IS NULL OR in_inventory_id = '' THEN
    SET in_inventory_id = CONCAT('INV-', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND()*10000),4,'0'));
END IF;

-- 입고 상태 변경
UPDATE inbound
SET Inbound_status = 1,
    inbound_process_date = NOW()
WHERE inbound_id = in_inbound_id;

-- 재고 수량 증가 및 출고일 업데이트
UPDATE inventory
SET quantity = quantity + in_quantity,
    last_inbound_date = NOW()
WHERE client_id = in_client_id
  AND ware_id = in_ware_id
  AND warehouse_pos_x = in_pos_x
  AND warehouse_pos_y = in_pos_y
  AND prod_id = in_prod_id;

-- 재고 없으면 INSERT (REPLACE 써도 가능)
INSERT INTO inventory
(inventory_id, prod_id, client_id, quantity, ware_id, last_inbound_date, warehouse_pos_x, warehouse_pos_y)
SELECT in_inventory_id,in_prod_id,in_client_id,in_quantity,in_ware_id,now(),in_pos_x,in_pos_y
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM inventory
    WHERE client_id = in_client_id
      AND ware_id = in_ware_id
      AND warehouse_pos_x = in_pos_x
      AND warehouse_pos_y = in_pos_y
      AND prod_id = in_prod_id
);

UPDATE userWareHouse
SET warehouse_usage =
        IFNULL(warehouse_usage, 0)
            + IFNULL(in_new_usage, 0)
WHERE client_id = in_client_id
  AND ware_id   = in_ware_id
  AND warehouse_pos_x = in_pos_x
  AND warehouse_pos_y = in_pos_y;

COMMIT;
END $$

DELIMITER ;
-- ---------------------------------------------------------------------
-- 3. 출고 요청 프로시저
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS outbound_request;

DELIMITER //

CREATE PROCEDURE outbound_request(IN in_inventoryId VARCHAR(50), IN in_quantity INTEGER )
BEGIN
    -- 필요한 데이터 임시 저장
    DECLARE set_prodId VARCHAR(50);
    DECLARE set_clientId VARCHAR(50);
    DECLARE set_wareId VARCHAR(50);
    DECLARE set_warehousePosX VARCHAR(5);
    DECLARE set_warehousePosY INT;
    DECLARE set_outboundId VARCHAR(50);
    -- 1. inventory 테이블에서 필요한 데이터 SELECT
SELECT i.prod_id, i.client_id,  i.ware_id, i.warehouse_pos_x, i.warehouse_pos_y
INTO set_prodId, set_clientId, set_wareId, set_warehousePosX, set_warehousePosY
FROM inventory i
WHERE i.inventory_id = in_inventoryId;

-- inbound_id 생성
    SET set_outboundId = CONCAT('OUT-', DATE_FORMAT(NOW(), '%Y%m%d'), LPAD(FLOOR(RAND() * 10000), 4, '0'));
-- 2. SELECT로 가져온 값으로 INSERT

INSERT INTO outbound (
    outbound_id, prod_id, client_id, quantity, status, req_outbound_date, ware_id, warehouse_pos_x, warehouse_pos_y
)
VALUES (
          set_outboundId, set_prodId, set_clientId, in_quantity, 0, now(), set_wareId, set_warehousePosX, set_warehousePosY
       );
END //

DELIMITER ;

-- ---------------------------------------------------------------------
-- 4. 창고 가용면적 재계산 트리거
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_update_available_space_userwarehouse_update;

DELIMITER //

-- AFTER UPDATE 트리거
CREATE TRIGGER trg_update_available_space_userwarehouse_update
    AFTER UPDATE ON userWareHouse
    FOR EACH ROW
BEGIN
    DECLARE total_usage DECIMAL(10, 2);
    DECLARE total_size DECIMAL(10, 2);

    -- userWareHouse로부터 해당 창고의 전체 사용량 계산
    SELECT IFNULL(SUM(warehouse_usage), 0)
    INTO total_usage
    FROM userWareHouse
    WHERE ware_id = NEW.ware_id;

    -- warehouse_area의 총 크기 조회
    SELECT ware_total_size
    INTO total_size
    FROM warehouse_area
    WHERE ware_id = NEW.ware_id;

    -- available_space 업데이트
    UPDATE warehouse_area
    SET available_space = GREATEST(total_size - total_usage, 0)
    WHERE ware_id = NEW.ware_id;
END //

DELIMITER ;

-- ---------------------------------------------------------------------
-- 참고: Inbound.sql 의 DB_inbound_check_client_read 프로시저는 원본이
--       "AND i.warehouse" 에서 끊긴 미완성 상태라 여기에 포함하지 않았습니다.
--       현재 입고 승인은 inbound_approve 프로시저로 처리됩니다.
-- ---------------------------------------------------------------------
