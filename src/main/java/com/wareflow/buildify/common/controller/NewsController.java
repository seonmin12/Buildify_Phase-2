package com.wareflow.buildify.common.controller;

import com.wareflow.buildify.cache.NewsCache;
import com.wareflow.buildify.dto.NewsItemDTO;
import com.wareflow.buildify.util.NewsUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

// 대시보드 뉴스 위젯용 API
// 브라우저에서 외부 사이트를 직접 부르지 않고 서버가 대신 조회합니다. (CORS / API 키 불필요)
@RestController
@RequiredArgsConstructor
@Log4j2
public class NewsController {

    private static final String DEFAULT_KEYWORD = "물류";

    private final NewsUtil newsUtil;

    @GetMapping("/api/news")
    public List<NewsItemDTO> getNews(@RequestParam(value = "q", required = false) String keyword) {
        NewsCache cache = NewsCache.getInstance();
        if (cache.isExpired()) {
            String q = (keyword == null || keyword.isBlank()) ? DEFAULT_KEYWORD : keyword;
            cache.setNewsCache(newsUtil.fetchNews(q));
        }
        return cache.getNewsCache();
    }
}
