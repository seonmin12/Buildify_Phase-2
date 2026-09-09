package com.wareflow.buildify.util;

import com.wareflow.buildify.dto.NewsItemDTO;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

// 📰 NewsUtil: 구글 뉴스 RSS 에서 물류 관련 기사를 가져오는 유틸 클래스
// NewsUtil: Fetches logistics news from Google News RSS.
//
// 기존에는 NewsAPI + 외부 CORS 프록시(allorigins.win)를 브라우저에서 직접 호출했으나,
//   - API 키가 JSP 에 그대로 노출되고
//   - NewsAPI 무료 플랜은 배포 도메인에서의 호출이 제한되며
//   - 공용 무료 프록시에 의존해 불안정
// 하다는 문제가 있어, 키가 필요 없는 구글 뉴스 RSS 를 서버에서 조회하는 방식으로 바꿨습니다.
@Component
@Log4j2
public class NewsUtil {

    private static final String RSS_URL_FORMAT =
            "https://news.google.com/rss/search?q=%s&hl=ko&gl=KR&ceid=KR:ko";
    private static final int MAX_ITEMS = 30;
    private static final int TIMEOUT_MS = 5000;

    public List<NewsItemDTO> fetchNews(String keyword) {
        List<NewsItemDTO> items = new ArrayList<>();
        HttpURLConnection conn = null;
        try {
            String url = String.format(RSS_URL_FORMAT, URLEncoder.encode(keyword, StandardCharsets.UTF_8));
            conn = (HttpURLConnection) new URL(url).openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            // User-Agent 가 없으면 구글이 응답을 거부하는 경우가 있습니다.
            conn.setRequestProperty("User-Agent", "Mozilla/5.0 (compatible; BuildifyWMS/1.0)");

            if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
                log.warn("뉴스 RSS 응답 코드 {} - 뉴스 위젯을 비웁니다.", conn.getResponseCode());
                return items;
            }

            try (InputStream in = conn.getInputStream()) {
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                // 외부 엔티티 참조 차단 (XXE 방지)
                factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
                factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
                factory.setXIncludeAware(false);
                factory.setExpandEntityReferences(false);

                DocumentBuilder builder = factory.newDocumentBuilder();
                Document doc = builder.parse(in);

                NodeList nodes = doc.getElementsByTagName("item");
                int size = Math.min(nodes.getLength(), MAX_ITEMS);
                for (int i = 0; i < size; i++) {
                    Node node = nodes.item(i);
                    if (node.getNodeType() != Node.ELEMENT_NODE) {
                        continue;
                    }
                    Element el = (Element) node;
                    items.add(NewsItemDTO.builder()
                            .title(text(el, "title"))
                            .url(text(el, "link"))
                            .source(text(el, "source"))
                            .pubDate(text(el, "pubDate"))
                            .build());
                }
            }
            log.info("뉴스 {}건 조회 완료 (keyword={})", items.size(), keyword);

        } catch (Exception e) {
            // 뉴스는 부가 기능이므로 실패해도 대시보드 전체를 막지 않습니다.
            log.warn("뉴스 조회 실패 - 빈 목록을 반환합니다. ({})", e.toString());
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
        return items;
    }

    private String text(Element parent, String tagName) {
        NodeList list = parent.getElementsByTagName(tagName);
        if (list.getLength() == 0) {
            return "";
        }
        String value = list.item(0).getTextContent();
        return value == null ? "" : value.trim();
    }
}
