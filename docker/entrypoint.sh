#!/usr/bin/env bash
# =====================================================================
# 컨테이너 시작 시 환경변수로부터 application-secret.properties 를 생성합니다.
#
# 이 앱은 설정을 오직 classpath 의 application-secret.properties 에서만 읽습니다.
#   - root-context.xml  : <context:property-placeholder location="classpath:application-secret.properties"/>
#   - SecretPropertiesLoader / GeoUtil : getResourceAsStream("application-secret.properties")
#
# 자바 코드와 Spring XML 을 건드리지 않고 도커화하기 위해,
# 기존 로딩 메커니즘은 그대로 두고 파일만 런타임에 만들어 줍니다.
# =====================================================================
set -euo pipefail

CLASSES_DIR="/usr/local/tomcat/webapps/ROOT/WEB-INF/classes"
SECRET_FILE="${CLASSES_DIR}/application-secret.properties"

# ---------- 필수값 검증 ----------
: "${DB_USERNAME:?DB_USERNAME 환경변수가 필요합니다 (.env 확인)}"
: "${DB_PASSWORD:?DB_PASSWORD 환경변수가 필요합니다 (.env 확인)}"

DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-buildifydb}"
DB_DRIVER="${DB_DRIVER:-com.mysql.cj.jdbc.Driver}"

# DB_URL 을 직접 주면 그대로 쓰고(RDS 등), 없으면 호스트/포트/DB명으로 조립합니다.
DB_URL="${DB_URL:-jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?serverTimezone=Asia/Seoul&characterEncoding=UTF-8&useSSL=false&allowPublicKeyRetrieval=true}"

# 외부 API 키는 없어도 기동은 되도록 빈 문자열을 기본값으로 둡니다.
#  - openweather.api.key 는 @Value 로 주입되므로 "키가 없는 것"과 "프로퍼티가 없는 것"은 다릅니다.
#    프로퍼티 자체가 없으면 기동이 실패하므로, 값이 비어 있더라도 키는 반드시 써 줘야 합니다.
KAKAO_REST_KEY="${KAKAO_REST_KEY:-}"
KAKAO_JAVASCRIPT_KEY="${KAKAO_JAVASCRIPT_KEY:-}"
OPENWEATHER_API_KEY="${OPENWEATHER_API_KEY:-}"

mkdir -p "${CLASSES_DIR}"

cat > "${SECRET_FILE}" <<EOF
# 이 파일은 컨테이너 시작 시 entrypoint.sh 가 환경변수로부터 생성합니다.
# 직접 수정하지 마세요. 값은 .env / 배포 환경의 환경변수에서 관리합니다.
application-secret.driver=${DB_DRIVER}
application-secret.url=${DB_URL}
application-secret.username=${DB_USERNAME}
application-secret.password=${DB_PASSWORD}

kakao.rest.key=${KAKAO_REST_KEY}
kakao.javascript.key=${KAKAO_JAVASCRIPT_KEY}
openweather.api.key=${OPENWEATHER_API_KEY}
EOF

chmod 600 "${SECRET_FILE}"

# 비밀번호는 가린 채로 확인용 로그만 남깁니다.
echo "[entrypoint] application-secret.properties 생성 완료"
echo "[entrypoint]   url      = ${DB_URL}"
echo "[entrypoint]   username = ${DB_USERNAME}"
for pair in "kakao.rest.key:${KAKAO_REST_KEY}" \
            "kakao.javascript.key:${KAKAO_JAVASCRIPT_KEY}" \
            "openweather.api.key:${OPENWEATHER_API_KEY}"; do
  name="${pair%%:*}"
  value="${pair#*:}"
  if [ -z "${value}" ]; then
    echo "[entrypoint]   ${name} 미설정 - 해당 기능(지도/날씨)은 비활성 상태로 동작합니다"
  fi
done

exec "$@"
