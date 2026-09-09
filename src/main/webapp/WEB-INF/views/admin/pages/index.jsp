<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<style>
    .dashboard-container {
      padding: 40px 24px;
      background: linear-gradient(to bottom right, #f0f4f8, #ffffff);
      display: flex;
      flex-direction: column;
      gap: 40px;
      min-height: 100vh;
    }

    .dashboard-main {
      display: flex;
      gap: 24px;
    }

    .left-column {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }

    .right-column {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .status-area {
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 30px;
    }

    .status-left {
      display: flex;
      flex-direction: column;
      gap: 20px;
      flex: 1;
    }

    .status-row {
      display: flex;
      align-items: center;
      /*gap: 10px;*/
    }

    .status-box {
      background-color: #a9c9f3;
      color: #fff;
      padding: 16px 32px;
      border-radius: 10px;
      font-weight: 600;
      margin-left: 50px;
      margin-right: 50px;
      font-size: 18px;
      min-width: 160px;
      text-align: center;
    }

    .arrow-icon {
      font-size: 20px;
      color: #5a82b7;
    }

    .highlight-box {
      background-color: #d293e1;
      color: white;
      padding: 16px 32px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 18px;
      min-width: 180px;
      text-align: center;
    }
    .chart-container {
      display: flex;
      gap: 30px;
      flex-wrap: wrap;
    }
    .chart-box {
      flex: 1 1 45%;
      background-color: white;
      border: 1px solid #ddd;
      border-radius: 12px;
      padding: 16px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.04);
    }
    .chart-box h3 {
      margin-bottom: 12px;
      color: #333;
      font-size: 16px;
      font-weight: 700;
    }

    .status-area {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 30px;
    }

    .status-flow-box {
      flex: 1 1 75%;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }


    .status-box {
      background-color: #a9c9f3;
      color: #fff;
      padding: 16px 32px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 18px;
      min-width: 160px;
      text-align: center;
    }

    .arrow-icon {
      font-size: 20px;
      color: #5a82b7;
    }




    .notice-card {
      flex: 1;
      width: 100%;
      background-color: #eb5c5c;
      padding: 20px 24px;
      border-radius: 10px;
      color: white;
      font-weight: bold;
      height: 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }

    .notice-card h3 {
      font-size: 14px;
      margin-bottom: 12px;
    }

    .notice-card ul {
      list-style-type: disc;
      padding-left: 20px;
      font-size: 12px;
    }

    /* Weather card: grid layout */
    .weather-list {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      padding: 0;
      margin: 0;
      list-style: none;
    }
    .weather-item {
      flex: 1;
      background-color: rgba(255, 255, 255, 0.2);
      padding: 12px;
      border-radius: 8px;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .weather-item .city {
      font-weight: 700;
      margin-bottom: 4px;
    }
    .weather-item .desc {
      font-size: 0.9em;
      margin-bottom: 6px;
    }
    .weather-item .temp {
      font-size: 1.2em;
      font-weight: 600;
    }
    .status-area {
      width: 100%;
      display: flex;
      justify-content: center;
    }

    .status-row-group {
        flex: 3;
        display: flex;
        flex-direction: column;
        gap: 10px;
        align-items: center; /* 중앙 정렬 */
    }

    .status-row {
      display: flex;
      justify-content: flex-start;
      align-items: center;
      /*gap: 10px;*/
      /*flex-wrap: wrap;*/
    }

    .status-area.unified-status {
        display: flex;
        justify-content: center; /* 중앙 정렬 */
        align-items: flex-start;
        gap: 30px;
        width: 100%;
        margin: 0 auto;
        flex-wrap: wrap;
    }

    .middle-box {
      background-color: #88c0d0;
      color: #fff;
      width: 100%;
      min-height: 140px;
      padding: 16px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
    }

    /* 오른쪽 정렬 및 행 높이 유지: .status-area.unified-status 내에서만 적용 */
    .status-area.unified-status .notice-card {
      margin-left: auto;
    }

    .notice-card {
      flex: 1;
      background-color: #4aa6c3;
      padding: 24px 28px;
      border-radius: 10px;
      color: #ffffff;
      width: 100%;
      font-weight: bold;
      min-height: 140px;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }
    #news-list li {
      opacity: 1 !important;
      transform: none !important;
      animation: none !important;
    }

    @keyframes fadeInUp {
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    @media (max-width: 1024px) {
      .status-area.unified-status {
        flex-direction: column;
        align-items: stretch;
      }

      .status-row-group {
        width: 100%;
        max-width: 100%;
      }

      .notice-card {
        width: 100%;
        margin-top: 20px;
      }

        .status-area.unified-status {
            flex-direction: column;
            align-items: center;
        }

        .status-row-group {
            width: 100%;
            max-width: 100%;
            align-items: center;
        }
    }

    @media (max-width: 480px) {
      .status-box,
      .highlight-box {
        font-size: 14px;
        padding: 12px 16px;
      }

      .arrow-icon {
        display: none;
      }

      .notice-card h3 {
        font-size: 13px;
        margin-bottom: 8px;
      }

      .notice-card ul {
        font-size: 11px;
        padding-left: 16px;
      }

      .chart-box h3 {
        font-size: 16px;
        margin-bottom: 12px;
      }

      .chart-box h1 {
        font-size: 18px;
      }
    }
    @media (max-width: 784px) {
      .arrow-icon {
        display: none !important;
      }
      .chart-container {
        flex-direction: column;
      }
    }
  </style>

<head>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

  <div class="dashboard-container">
    <h1 style="font-size: 24px; font-weight: bold; margin-left: 24px;">📊 관리자 대시보드</h1>
    <div class="dashboard-main">
      <div class="left-column">
        <!-- 상태 영역 -->
        <div class="status-area unified-status">
          <div class="status-row-group">
            <div style="display: flex; flex-direction: column; gap: 10px;">
              <div class="status-row">
                <div class="status-box">오늘의 입고요청 : ${todayInboundStat.requestCount} 건</div>
<%--                <div class="arrow-icon">➜</div>--%>
                <div class="status-box">오늘의 입고승인 : ${todayInboundStat.approvalCount} 건</div>
              </div>
              <div class="status-row">
                <div class="status-box">오늘의 출고요청 : ${todayOutboundStat.requestCount} 건</div>
<%--                <div class="arrow-icon">➜</div>--%>
                <div class="status-box">오늘의 출고승인 : ${todayOutboundStat.approvalCount} 건</div>
              </div>
            </div>
          </div>
        </div>

        <!-- 중간 박스 -->
<%--        <div class="middle-box">--%>
<div style="background: white; border: 1px solid black; color: black; width: 100%; border-radius: 10px; padding: 20px; display: flex; justify-content: center;">
  <div style="display: flex; gap: 40px;">
    <c:forEach var="w" items="${wareHouseDashBoardDTOList}">
      <div style="text-align: center; display: flex; flex-direction: column; align-items: center;">
        <div style="font-size: 20px; font-weight: bold; margin-bottom: 12px;">${w.wareId}</div>
        <div style="display: flex; flex-direction: row; gap: 16px; margin-bottom: 8px;">
          <!-- 계약률 박스 -->
          <div style="position: relative; width: 48px; height: 80px; border: 1px solid #b0b0b0; border-radius: 8px; overflow: hidden; background-color: #f5f5f5;">
            <div style="position: absolute; bottom: 0; width: 100%; height: ${(w.contractRate * 100).intValue()}%; background-color: ${(w.contractRate * 100).intValue() >= 90 ? '#e74c3c' : '#4aa6c3'};"></div>
            <div style="position: absolute; width: 100%; text-align: center; top: 50%; transform: translateY(-50%); font-size: 13px; color: #333333; font-weight: bold;">
              ${(w.contractRate * 100).intValue()}%
            </div>
          </div>
          <!-- 가용률 박스 -->
          <div style="position: relative; width: 48px; height: 80px; border: 1px solid #b0b0b0; border-radius: 8px; overflow: hidden; background-color: #f5f5f5;">
            <div style="position: absolute; bottom: 0; width: 100%; height: ${(w.usageRate * 100).intValue()}%; background-color: ${(w.usageRate * 100).intValue() >= 90 ? '#e74c3c' : '#4aa6c3'};"></div>
            <div style="position: absolute; width: 100%; text-align: center; top: 50%; transform: translateY(-50%); font-size: 13px; color: #333333; font-weight: bold;">
              ${(w.usageRate * 100).intValue()}%
            </div>
          </div>
        </div>
        <div style="display: flex; gap: 34px; font-size: 12px;">
          <div>계약률</div>
          <div>사용률</div>
        </div>
      </div>
    </c:forEach>
  </div>
</div>
<%--        </div>--%>

        <!-- 날씨 박스 -->
        <div style="background: white; border: black; color: black; width: 100%; min-height: 140px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-weight: bold;">
            <!-- 날씨 카드 -->
            <div class="notice-card">
                <h3>🌤 지역별 실시간 날씨</h3>
                <ul class="weather-list">
                  <c:forEach var="w" items="${weatherInfoDTOList}">
                    <li class="weather-item">
                      <div class="city">${w.city}</div>
                      <div class="desc">${w.emoji} ${w.description}</div>
                      <c:set var="tempStr">${w.temp}</c:set>
                      <div class="temp">
                        <%-- API 키 미설정/조회 실패 시 NaN 이 그대로 노출되지 않도록 처리 --%>
                        <c:choose>
                          <c:when test="${fn:contains(tempStr, 'NaN')}">–</c:when>
                          <c:otherwise>${tempStr}°C</c:otherwise>
                        </c:choose>
                      </div>
                    </li>
                  </c:forEach>
                </ul>
            </div>
        </div>

        <!-- 뉴스 카드 -->
        <div class="notice-card">
          <h3>📢 실시간 물류 뉴스</h3>
          <ul id="news-list">
            <li><em>로딩 중...</em></li>
          </ul>
        </div>
      </div>
      <div class="right-column">
        <div class="chart-box">
          <h3>주간 입고 현황</h3>
          <canvas id="inboundChart" width="400" height="145"></canvas>
        </div>
        <div class="chart-box">
          <h3>주간 출고 현황</h3>
          <canvas id="outboundChart" width="400" height="145"></canvas>
        </div>
      </div>
    </div>
  </div>

<script>
  let allArticles = [];
  let currentIndex = 0;

  function rotateNews() {
    console.log("🌀 rotateNews 실행됨");
    console.log("🧾 뉴스 데이터:", allArticles);
    const list = document.getElementById("news-list");
    list.innerHTML = "";

    if (allArticles.length === 0) return;

    if (currentIndex >= allArticles.length) {
      currentIndex = 0;
    }

    const endIndex = Math.min(currentIndex + 3, allArticles.length);
    const slice = allArticles.slice(currentIndex, endIndex);

    slice.forEach(article => {
      if (!article || !article.title) return;
      const li = document.createElement("li");
      const a = document.createElement("a");
      a.href = article.url;
      a.target = "_blank";
      a.textContent = article.title;
      a.style.display = "block";
      a.style.padding = "4px";
      a.style.color = "#ffffff";
      a.style.textDecoration = "underline";
      li.appendChild(a);
      list.appendChild(li);
    });

    currentIndex += 3;
  }

  function loadNews() {
    // 서버가 구글 뉴스 RSS 를 대신 조회해 JSON 으로 내려줍니다. (API 키 / 외부 프록시 불필요)
    fetch("<c:url value='/api/news'/>")
      .then(res => res.json())
      .then(articles => {
        if (!Array.isArray(articles) || articles.length === 0) {
          throw new Error("No articles found");
        }
        allArticles = articles;
        currentIndex = 0;
        rotateNews();
      })
      .catch(err => {
        console.error("🛑 loadNews error:", err);
        const list = document.getElementById("news-list");
        list.innerHTML = "<li>뉴스를 불러오는 데 실패했습니다.</li>";
      });
  }

  window.addEventListener("load", function () {
    console.log("📦 DOM fully loaded");
    loadNews();
    setInterval(rotateNews, 15000);
    setInterval(loadNews, 900000);

    const inboundChartData2 = {
      "date": ["2024-04-22"],
      "requestCount": [2],
      "approvalCount": [1]
    };
    console.log(inboundChartData2.requestCount);

    const inboundChartData = JSON.parse('<c:out value="${inboundChartData}" escapeXml="false" />');
    const outboundChartData = JSON.parse('<c:out value="${outboundChartData}" escapeXml="false" />');

    const inboundMaxValue = Math.max(...inboundChartData.requestCount.slice(-7), ...inboundChartData.approvalCount.slice(-7));
    const outboundMaxValue = Math.max(...outboundChartData.requestCount.slice(-7), ...outboundChartData.approvalCount.slice(-7));
    // max(최대값)에 +1을 더해 실제 최대값이 y축 끝에 딱 맞아 떨어져 여유가 없는 문제를 해결
    const inboundSuggestedMax = Math.ceil(inboundMaxValue * 1.2) + 1;
    const outboundSuggestedMax = Math.ceil(outboundMaxValue * 1.2) + 1;


    // Chart.js charts for 입고/출고 현황
    const inboundCtx = document.getElementById('inboundChart').getContext('2d');
    const inboundChart = new Chart(inboundCtx, {
      type: 'bar',
      data: {
        labels: inboundChartData.date.slice(-7),
        datasets: [{
          type: 'bar',
          label: '입고 요청',
          data: inboundChartData.requestCount.slice(-7),
          backgroundColor: 'rgba(75, 192, 192, 0.6)'
        }, {
          type: 'line',
          label: '입고 승인',
          data: inboundChartData.approvalCount.slice(-7),
          borderColor: 'rgba(153, 102, 255, 0.8)',
          backgroundColor: 'rgba(153, 102, 255, 0.2)',
          fill: false,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: '주간 입고 현황'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            suggestedMax: inboundSuggestedMax,
            grace: '20%'
          }
        }
      }
    });

    const outboundCtx = document.getElementById('outboundChart').getContext('2d');
    const outboundChart = new Chart(outboundCtx, {
      type: 'bar',
      data: {
        labels: outboundChartData.date.slice(-7),
        datasets: [{
          type: 'bar',
          label: '출고 요청',
          data: outboundChartData.requestCount.slice(-7),
          backgroundColor: 'rgba(75, 192, 192, 0.6)'
        }, {
          type: 'line',
          label: '출고 승인',
          data: outboundChartData.approvalCount.slice(-7),
          borderColor: 'rgba(153, 102, 255, 0.8)',
          backgroundColor: 'rgba(153, 102, 255, 0.2)',
          fill: false,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: '주간 출고 현황'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            suggestedMax: outboundSuggestedMax,
            grace: '20%'
          }
        }
      }
    });
  });

</script>


</body>