package com.wareflow.buildify.cache;

import com.wareflow.buildify.dto.NewsItemDTO;

import java.util.Collections;
import java.util.List;

// 뉴스 캐시: 대시보드를 열 때마다 외부 RSS 를 호출하지 않도록 일정 시간 결과를 보관합니다.
public class NewsCache {

    private static final NewsCache instance = new NewsCache();
    private static final long TTL_MILLIS = 10 * 60 * 1000L; // 10분

    private List<NewsItemDTO> newsItemDTOList = Collections.emptyList();
    private long lastUpdatedAt = 0L;

    private NewsCache() {
    }

    public static NewsCache getInstance() {
        return instance;
    }

    public synchronized boolean isExpired() {
        return newsItemDTOList.isEmpty() || System.currentTimeMillis() - lastUpdatedAt > TTL_MILLIS;
    }

    public synchronized List<NewsItemDTO> getNewsCache() {
        return newsItemDTOList;
    }

    public synchronized void setNewsCache(List<NewsItemDTO> newsItemDTOList) {
        this.newsItemDTOList = newsItemDTOList == null ? Collections.emptyList() : newsItemDTOList;
        this.lastUpdatedAt = System.currentTimeMillis();
    }
}
