# =====================================================================
# BuildiFy WMS - Dockerfile
#
# 이 프로젝트는 Spring Boot 가 아니라 순수 Spring MVC 5.3 WAR 입니다.
# 따라서 fat JAR + `java -jar` 가 아니라,
# 서블릿 컨테이너(Tomcat 9) 이미지에 WAR 를 얹는 고전적인 방식으로 배포합니다.
#
#   - javax.servlet 4.0.1 을 쓰므로 Tomcat 9.x 고정 (10+ 는 jakarta 라 동작하지 않음)
#   - 로그인 성공 후 "/admin/pages/index" 처럼 루트 기준 절대경로로 리다이렉트하므로
#     반드시 ROOT 컨텍스트(/)로 배포해야 함
# =====================================================================

# ---------- 1) 빌드 스테이지 ----------
FROM gradle:8.13-jdk17 AS build
WORKDIR /workspace

# 의존성 캐시 레이어: 빌드 스크립트만 먼저 복사해 두면
# 소스만 바뀔 때 의존성 다운로드를 다시 하지 않습니다.
COPY build.gradle settings.gradle ./
RUN gradle --no-daemon dependencies --configuration runtimeClasspath > /dev/null 2>&1 || true

COPY src ./src

# 테스트는 살아있는 MySQL 을 요구하므로(테스트가 root-context.xml 을 직접 로드) 이미지 빌드에서는 제외합니다.
RUN gradle --no-daemon war -x test

# ---------- 2) 런타임 스테이지 ----------
FROM tomcat:9.0-jdk17-temurin

ENV TZ=Asia/Seoul \
    JAVA_OPTS="-Xms256m -Xmx512m -Duser.timezone=Asia/Seoul -Dfile.encoding=UTF-8"

# 기본 예제 앱(ROOT, manager 등) 제거
RUN rm -rf /usr/local/tomcat/webapps/*

# WAR 를 ROOT 컨텍스트로 "펼쳐서" 배치합니다.
# 펼쳐 두어야 컨테이너 시작 시 entrypoint 가
# WEB-INF/classes/application-secret.properties 를 생성해 넣을 수 있습니다.
COPY --from=build /workspace/build/libs/*.war /tmp/ROOT.war
RUN mkdir -p /usr/local/tomcat/webapps/ROOT \
    && cd /usr/local/tomcat/webapps/ROOT \
    && jar xf /tmp/ROOT.war \
    && rm -f /tmp/ROOT.war

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["catalina.sh", "run"]
