package com.buildify.wms.mapperTests;

import com.wareflow.buildify.domain.auth.login.mapper.AuthMapper;
import com.wareflow.buildify.vo.AuthVO;
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
public class AuthMapperTests {

    @Autowired
    private AuthMapper authMapper;

    @Test
    @Transactional
    public void testFindById() {
        AuthVO authVO = authMapper.findById("user01");
        log.info("---------------" + authVO);
    }
}
