package com.buildify.wms.mapperTests;

import com.wareflow.buildify.domain.auth.login.mapper.AdminLoginMapper;
import com.wareflow.buildify.vo.AdminVO;
import lombok.extern.log4j.Log4j2;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = {
        "file:src/main/webapp/WEB-INF/root-context.xml"
})
@MapperScan(basePackages = "com.wareflow.buildify.domain.auth.login.mapper")
@Log4j2
public class AdminLoginMapperTests {
    @Autowired
    private AdminLoginMapper adminLoginMapper;

    @Test
    @Transactional
    public void testFindByUsername() {
        AdminVO adminVO = adminLoginMapper.findById("admin01");
        log.info("admin : " + adminVO.toString());
    }
}
