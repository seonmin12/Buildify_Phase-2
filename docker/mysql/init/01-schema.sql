# DROP DATABASE IF EXISTS buildifydb;
# CREATE DATABASE buildifydb;

-- 사용할 데이터베이스 지정
-- (Docker) 데이터베이스는 compose 의 MYSQL_DATABASE 로 생성됩니다.
USE buildifydb;

-- ========================================
-- 테이블 삭제 - 외래키 순서 고려
-- ========================================
DROP TABLE IF EXISTS `inventory`;
DROP TABLE IF EXISTS `inbound`;
DROP TABLE IF EXISTS `outbound`;
DROP TABLE IF EXISTS `userWareHouse`;
DROP TABLE IF EXISTS `product`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `wareHouse`;
DROP TABLE IF EXISTS `warehouse_area`;
DROP TABLE IF EXISTS `admin`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `outbound_backup`;
DROP TABLE IF EXISTS `inbound_backup`;
DROP TABLE IF EXISTS `auth`;

-- ========================================
-- CREATE TABLE
-- ========================================

-- 창고 지역 정보 테이블
-- 창고 지역 정보 테이블: 창고의 지역, 주소, 총 크기 및 가용 공간 관리
CREATE TABLE `warehouse_area` (
                                  `ware_id` VARCHAR(10) NOT NULL,
                                  `ware_name` VARCHAR(20) NOT NULL,
                                  `ware_address` VARCHAR(50) NOT NULL,
                                  `ware_admin_number` VARCHAR(255) NOT NULL,
                                  `ware_total_size` DECIMAL(10,2) NOT NULL DEFAULT 0,
                                  `available_space` DECIMAL(10,2) NULL COMMENT '창고별 가용량 (available_space = contract_area - warehouse_usage)',
                                  PRIMARY KEY (`ware_id`)
);

-- 창고 위치 테이블
-- 창고 위치 테이블: 창고의 위치, 사용량 및 계약 면적 관리
CREATE TABLE `wareHouse` (
                             `ware_id` VARCHAR(10) NOT NULL,
                             `warehouse_pos_x` VARCHAR(255) NOT NULL,
                             `warehouse_pos_y` INT NOT NULL,
                             `area_size` DECIMAL(10,2) NOT NULL,
                             `rental_fee` INT NOT NULL COMMENT '월 지불 단위',
                             PRIMARY KEY (`ware_id`)
);

-- 회원 창고 정보 테이블
-- 회원 창고 정보 테이블: 사용자의 창고 위치 및 임대 정보 관리
CREATE TABLE `userWareHouse` (
                             `ware_id` VARCHAR(10) NOT NULL,
                             `client_id` VARCHAR(255) NOT NULL,
                             `warehouse_pos_x` VARCHAR(255) NOT NULL,
                             `warehouse_pos_y` INT NOT NULL,
                             `warehouse_usage` DECIMAL(10,2) NOT NULL,
                             `contract_area` DECIMAL(10,2) NOT NULL,
                             `ware_start_date` DATE NOT NULL,
                             `ware_end_date` DATE NOT NULL,
                             PRIMARY KEY (`ware_id`)
);

-- 사용자 정보 테이블
-- 사용자 정보 테이블: 회원의 개인 정보 및 가입 정보 관리
CREATE TABLE `user` (
                        `client_id` VARCHAR(255) NOT NULL COMMENT '[접두어]-[날짜]-[랜덤문자열]',
                        `user_name` VARCHAR(20) NOT NULL,
                        `user_phone` VARCHAR(15) NOT NULL COMMENT '하이픈 없는형태 + 국제번호',
                        `user_email` VARCHAR(30) NOT NULL,
                        `user_address` VARCHAR(50) NOT NULL,
                        `business_number` VARCHAR(30) NOT NULL,
                        `user_enterdate` DATE NOT NULL COMMENT '회원가입 승인이 된 날짜 기준',
                        `user_id` VARCHAR(15) NOT NULL,
                        `user_pw` VARCHAR(100) NOT NULL,
                        `user_status` TINYINT(1) NOT NULL COMMENT '미승인/승인으로 나뉜다',
                        PRIMARY KEY (`client_id`)
);

-- 관리자 정보 테이블
-- 관리자 정보 테이블: 관리자 계정 및 권한 관리
CREATE TABLE `admin` (
                         `admin_number` VARCHAR(255) NOT NULL COMMENT '[접두어]-[날짜]-[랜덤문자열]',
                         `admin_role` VARCHAR(10) NOT NULL COMMENT '총관리자,창고관리자',
                         `admin_name` VARCHAR(20) NOT NULL,
                         `admin_email` VARCHAR(30) NOT NULL,
                         `admin_enter_date` DATE NOT NULL COMMENT '관리자 입사일',
                         `admin_address` VARCHAR(50) NULL,
                         `admin_phone` VARCHAR(15) NOT NULL,
                         `admin_id` VARCHAR(15) NOT NULL COMMENT '관리자 로그인 ID',
                         `admin_pw` VARCHAR(100) NOT NULL COMMENT '관리자 로그인 PW',
                         PRIMARY KEY (`admin_number`)
);

-- 제품 카테고리 테이블
-- 제품 카테고리 테이블: 제품 분류 및 카테고리 정보 관리
CREATE TABLE `category` (
                            `prod_categoryid` VARCHAR(255) NOT NULL COMMENT '[접두어]-[날짜]-[랜덤문자열]',
                            `category_level1` VARCHAR(255) NULL,
                            `category_level2` VARCHAR(255) NULL,
                            `category_level3` VARCHAR(255) NULL,
                            PRIMARY KEY (`prod_categoryid`)
);

-- 제품 정보 테이블
-- 제품 정보 테이블: 제품의 상세 정보 및 가격, 코드 관리
CREATE TABLE `product` (
                           `prod_id` VARCHAR(30) NOT NULL COMMENT '[접두어]-[날짜]-[랜덤문자열]',
                           `brand` VARCHAR(20) NOT NULL,
                           `prod_name` VARCHAR(30) NOT NULL,
                           `prod_price` INTEGER NULL,
                           `prod_code` INTEGER NULL COMMENT '중복 x',
                           `prod_size` DECIMAL(10,2) NOT NULL COMMENT 'cm^3.3 단위',
                           `prod_categoryid` VARCHAR(255) NOT NULL,
                           `client_id` VARCHAR(255) NULL,
                           PRIMARY KEY (`prod_id`)
);

-- 입고 요청 테이블
-- 입고 요청 테이블: 제품 입고 요청 및 처리 상태 관리
CREATE TABLE `inbound` (
                           `inbound_id` VARCHAR(255) NOT NULL,
                           `prod_id` VARCHAR(30) NOT NULL,
                           `client_id` VARCHAR(255) NOT NULL,
                           `quantity` INT NOT NULL,
                           `Inbound_status` INT NOT NULL DEFAULT 0 COMMENT '0 대기 / 1 승인 / 2 반려',
                           `req_inbound_date` DATETIME NULL,
                           `ware_id` VARCHAR(10) NULL,
                           `warehouse_pos_x` VARCHAR(255) NULL,
                           `warehouse_pos_y` INT NULL,
                           `inbound_process_date` DATETIME NULL,
                           PRIMARY KEY (`inbound_id`)
);

-- 출고 요청 테이블
-- 출고 요청 테이블: 제품 출고 요청 및 처리 상태 관리
CREATE TABLE `outbound` (
                            `outbound_id` VARCHAR(30) NOT NULL COMMENT 'timestamp???',
                            `prod_id` VARCHAR(30) NOT NULL,
                            `client_id` VARCHAR(255) NOT NULL,
                            `quantity` INT NOT NULL,
                            `status` INT NOT NULL DEFAULT 0,
                            `req_outbound_date` DATETIME NULL,
                            `ware_id` VARCHAR(10) NOT NULL,
                            `warehouse_pos_x` VARCHAR(255) NULL,
                            `warehouse_pos_y` INT NULL,
                            `outbound_process_date` DATETIME NULL,
                            PRIMARY KEY (`outbound_id`)
);

-- 재고 테이블
-- 재고 테이블: 제품별 재고 수량 및 위치 관리
CREATE TABLE `inventory` (
                            `inventory_id` VARCHAR(30) NOT NULL,
                             `prod_id` VARCHAR(30) NOT NULL,
                             `client_id` VARCHAR(255) NOT NULL,
                             `quantity` INT NOT NULL DEFAULT 0,
                             `ware_id` VARCHAR(10) NOT NULL,
                             `last_inbound_date` DATETIME NULL,
                             `last_outbound_date` DATETIME NULL,
                             `warehouse_pos_x` VARCHAR(255) NULL,
                             `warehouse_pos_y` INT NULL,
                             PRIMARY KEY (`inventory_id`)
);



-- 입고 요청 백업 테이블
-- 입고 요청 백업 테이블: 입고 요청 데이터 백업
CREATE TABLE `inbound_backup` (
                                  `inbound_id` VARCHAR(255) NOT NULL,
                                  `client_id` VARCHAR(255) NOT NULL,
                                  `quantity` INT NOT NULL,
                                  `Inbound_status` INT NOT NULL DEFAULT 0 COMMENT '0 대기 / 1 승인 / 2 반려',
                                  `req_inbound_day` DATETIME NULL,
                                  PRIMARY KEY (`inbound_id`)
);

-- 출고 요청 백업 테이블
-- 출고 요청 백업 테이블: 출고 요청 데이터 백업
CREATE TABLE `outbound_backup` (
                                   `outbound_id` VARCHAR(255) NOT NULL,
                                   `client_id` VARCHAR(255) NOT NULL,
                                   `quantity` INT NOT NULL,
                                   `Inbound_status` INT NOT NULL DEFAULT 0 COMMENT '0 대기 / 1 승인 / 2 반려',
                                   `req_inbound_day` DATETIME NULL,
                                   PRIMARY KEY (`outbound_id`)
);

-- 권한 테이블
CREATE TABLE `auth` (
                        `id`	VARCHAR(255)	NOT NULL,
                        `role`	VARCHAR(255)	NOT NULL	COMMENT '0 , 1, 2'
);

-- ========================================
-- 외래키(FK) 제약조건 설정
-- ========================================
ALTER TABLE `userWareHouse`
    ADD CONSTRAINT `FK_warehouse_TO_UserWareHouse_1` FOREIGN KEY (`ware_id`) REFERENCES `wareHouse` (`ware_id`);

ALTER TABLE `wareHouse`
    ADD CONSTRAINT `FK_warehouse_area_TO_warehouse_1` FOREIGN KEY (`ware_id`) REFERENCES `warehouse_area` (`ware_id`);

ALTER TABLE `inbound`
    ADD CONSTRAINT `FK_product_TO_inbound_1` FOREIGN KEY (`prod_id`) REFERENCES `product` (`prod_id`);

ALTER TABLE `outbound`
    ADD CONSTRAINT `FK_product_TO_outbound_1` FOREIGN KEY (`prod_id`) REFERENCES `product` (`prod_id`);

ALTER TABLE `inventory`
    ADD CONSTRAINT `FK_product_TO_inventory` FOREIGN KEY (`prod_id`) REFERENCES `product` (`prod_id`),
    ADD CONSTRAINT `FK_user_TO_inventory` FOREIGN KEY (`client_id`) REFERENCES `user` (`client_id`),
    ADD CONSTRAINT `FK_warehouse_TO_inventory` FOREIGN KEY (`ware_id`) REFERENCES `wareHouse` (`ware_id`);