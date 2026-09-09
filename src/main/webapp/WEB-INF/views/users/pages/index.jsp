<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>

    <meta charset="UTF-8">
    <title>유저 대시보드</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- 공통 CSS -->
    <link href="/static/css/app.css" rel="stylesheet">
    <link href="/static/css/custom.css" rel="stylesheet">

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- 페이지 전용 스타일 -->
    <style>
        .dashboard-container {
            padding: 40px 24px;
            background: linear-gradient(to bottom right, #f0f4f8, #ffffff);
            min-height: 100vh;
            font-family: 'Noto Sans KR', sans-serif;
        }

        .dashboard-main {
            display: flex;
            gap: 24px;
        }

        .left-column, .right-column {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .status-area.unified-status {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .status-row {
            display: flex;
            gap: 16px;
        }

        .status-box {
            background-color: #a9c9f3;
            color: #fff;
            padding: 16px 24px;
            border-radius: 8px;
            font-weight: 600;
            flex: 1;
            text-align: center;
        }

        .warehouse-section {
            margin: 24px 0;
        }

        .warehouse-section h3 {
            font-size: 18px;
            margin-bottom: 12px;
        }

        .warehouse-cards {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
        }

        .warehouse-card {
            flex: 1 1 30%;
            min-height: 100px;
            border: 2px dashed #ccc;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            background-color: cadetblue;   /* 연한 하늘색 예시 */
            padding: 16px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            font-style: italic;
        }

        .notice-card {
            background-color: #4aa6c3;
            color: #fff;
            padding: 20px;
            border-radius: 8px;
        }

        .notice-card h3 {
            margin-bottom: 12px;
            font-size: 16px;
        }

        .weather-list {
            display: flex;
            gap: 12px;
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .weather-item {
            background: rgba(255, 255, 255, 0.2);
            padding: 12px;
            border-radius: 6px;
            text-align: center;
            flex: 1;
        }

        .weather-item .city {
            font-weight: 700;
        }

        .weather-item .temp {
            font-size: 1.2em;
            margin-top: 4px;
        }

        .chart-box {
            background: #fff;
            border-radius: 8px;
            padding: 16px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
        }

        .chart-box h3 {
            margin-bottom: 12px;
            font-size: 16px;
        }

        .scrollable-warehouse-cards {
            max-height: 400px; /* 적절히 조절 가능 */
            overflow-y: auto;
            padding-right: 8px; /* 스크롤 여백 */
        }
        .scrollable-warehouse-cards::-webkit-scrollbar {
            width: 6px;
        }
        .scrollable-warehouse-cards::-webkit-scrollbar-thumb {
            background-color: #ccc;
            border-radius: 4px;
        }
    </style>
</head>
<body>
<div class="dashboard-container">
    <h1>📊 유저 대시보드</h1>
    <div class="dashboard-main">
        <!-- 왼쪽 컬럼 -->
        <div class="left-column">
            <!-- 오늘/주간 입출고 현황 -->
            <div class="status-area unified-status">
                <div class="status-row">
                    <div class="status-box">오늘 입고 요청: ${countDayInboundRequest} 건</div>
                    <div class="status-box">오늘 입고 승인: ${countDayInboundApproval} 건</div>
                </div>
                <div class="status-row">
                    <div class="status-box">오늘 출고 요청: ${countDayOutboundRequest} 건</div>
                    <div class="status-box">오늘 출고 승인: ${countDayOutboundApproval} 건</div>
                </div>
                <div class="status-row">
                    <div class="status-box">주간 입고 요청: ${countWeekInboundRequest} 건</div>
                    <div class="status-box">주간 입고 승인: ${countWeekInboundApproval} 건</div>
                </div>
                <div class="status-row">
                    <div class="status-box">주간 출고 요청: ${countWeekOutboundRequest} 건</div>
                    <div class="status-box">주간 출고 승인: ${countWeekOutboundApproval} 건</div>
                </div>
            </div>

            <!-- 플레이스홀더: 창고 섹션 -->
            <div class="warehouse-section">
                <h3>📦 내 창고 현황</h3>
                <div class="warehouse-cards scrollable-warehouse-cards">
                    <c:forEach var="w" items="${myWarehouses}">
                        <div class="warehouse-card">
                            <div>
                                <strong>위치:</strong> ${w.warehousePosX}${w.warehousePosY}<br/>
                                <strong>지역:</strong>
                                <c:choose>
                                    <c:when test="${w.wareId == 'W001'}">서울 창고</c:when>
                                    <c:when test="${w.wareId == 'W002'}">판교 창고</c:when>
                                    <c:when test="${w.wareId == 'W003'}">부산 창고</c:when>
                                    <c:when test="${w.wareId == 'W004'}">대구 창고</c:when>
                                    <c:when test="${w.wareId == 'W005'}">인천 창고</c:when>
                                </c:choose><br/>
                                <strong>사용률:</strong> ${w.warehouseUsage}%<br/>
                                <strong>남은 계약일:</strong> ${w.remainingDays}일
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>


            <!-- 오늘의 날씨 -->
            <div class="notice-card">
                <h3>🌤 오늘의 날씨</h3>
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

            <!-- 실시간 물류 뉴스 -->
            <div class="notice-card">
                <h3>📢 실시간 물류 뉴스</h3>
                <ul id="news-list">
                    <li>로딩 중...</li>
                </ul>
            </div>
        </div>

        <!-- 오른쪽 컬럼 -->
        <div class="right-column">
            <div class="chart-box">
                <h3>주간 입고 현황</h3>
                <canvas id="inboundChart"></canvas>
            </div>
            <div class="chart-box">
                <h3>주간 출고 현황</h3>
                <canvas id="outboundChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
    // 뉴스 로드 & 회전
    let allArticles = [], currentIndex = 0;

    function rotateNews() {
        const list = document.getElementById('news-list');
        list.innerHTML = '';
        if (!allArticles.length) return;
        allArticles.slice(currentIndex, currentIndex + 3)
            .forEach(a => {
                const li = document.createElement('li');
                const link = document.createElement('a');
                link.href = a.url;
                link.target = '_blank';
                link.textContent = a.title;
                li.appendChild(link);
                list.appendChild(li);
            });
        currentIndex = (currentIndex + 3) % allArticles.length;
    }

    function loadNews() {
        // 서버가 구글 뉴스 RSS 를 대신 조회해 JSON 으로 내려줍니다. (API 키 / 외부 프록시 불필요)
        fetch("<c:url value='/api/news'/>")
            .then(r => r.json())
            .then(articles => {
                allArticles = Array.isArray(articles) ? articles : [];
                rotateNews();
            })
            .catch(_ => {
                document.getElementById('news-list').innerHTML = '<li>뉴스 불러오기 실패</li>';
            });
    }

    function drawCharts() {
        var inboundData = [ ${countDayInboundRequest}, ${countDayInboundApproval},
            ${countWeekInboundRequest}, ${countWeekInboundApproval} ];
        var outboundData = [ ${countDayOutboundRequest}, ${countDayOutboundApproval},
            ${countWeekOutboundRequest}, ${countWeekOutboundApproval} ];

        var commonOptions = {
            responsive: true,
            maintainAspectRatio: false,  // → 높이를 고정해서 컨테이너에 꽉 차게
            legend: { display: false },  // → 데이터셋이 하나면 범례는 숨김
            layout: {
                padding: { top: 8, right: 8, bottom: 8, left: 8 }
            },
            scales: {
                xAxes: [{
                    gridLines: { display: false },  // → X축 그리드 없앰
                    ticks: {
                        fontSize: 12,
                        fontColor: '#666'
                    }
                }],
                yAxes: [{
                    gridLines: {
                        color: 'rgba(0,0,0,0.05)',     // → 연한 그리드
                        zeroLineColor: 'rgba(0,0,0,0.1)'
                    },
                    ticks: {
                        beginAtZero: true,
                        min: 0,
                        stepSize: 1,
                        fontSize: 12,
                        fontColor: '#666',
                        callback: function(v) { return v; }
                    }
                }]
            }
        };

        // 입고 차트
        new Chart(
            document.getElementById('inboundChart').getContext('2d'),
            {
                type: 'bar',
                data: {
                    labels: ['오늘 요청','오늘 승인','주간 요청','주간 승인'],
                    datasets: [{
                        label: '입고',
                        data: inboundData,
                        backgroundColor: 'rgba(75, 192, 192, 0.6)',  // → 은은한 바 색
                        barPercentage: 0.6
                    }]
                },
                options: commonOptions
            }
        );

        // 출고 차트
        new Chart(
            document.getElementById('outboundChart').getContext('2d'),
            {
                type: 'bar',
                data: {
                    labels: ['오늘 요청','오늘 승인','주간 요청','주간 승인'],
                    datasets: [{
                        label: '출고',
                        data: outboundData,
                        backgroundColor: 'rgba(153, 102, 255, 0.6)',
                        barPercentage: 0.6
                    }]
                },
                options: commonOptions
            }
        );
    }

    window.addEventListener('load', function() {
        loadNews();
        setInterval(rotateNews, 15000);
        drawCharts();
    });
</script>
</body>
</html>