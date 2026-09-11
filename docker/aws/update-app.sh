#!/usr/bin/env bash
# =====================================================================
# GHCR 의 최신 이미지를 확인해 애플리케이션을 교체합니다.
#
# 서버가 가져가는(pull) 방식을 쓰는 이유:
#   GitHub Actions 러너의 IP 는 매번 바뀌므로, Actions 가 서버로 SSH 하려면
#   22 번 포트를 전 세계에 열어야 합니다. 그 대신 서버가 주기적으로
#   새 이미지를 확인하도록 해서 인바운드 노출을 늘리지 않습니다.
#
# 설치: docker/aws/buildify-update.service / .timer 참고
#
# 주의: /usr/local/bin 으로 복사해 사용하므로, 이 스크립트 자체를 수정한 뒤에는
#       서버에서 다시 복사해야 반영됩니다.
#       sudo cp docker/aws/update-app.sh /usr/local/bin/
# =====================================================================
set -euo pipefail

REPO_DIR="${REPO_DIR:-/home/ec2-user/buildify}"
COMPOSE_FILES=(
  -f docker-compose.yml
  -f docker-compose.prod.yml
  -f docker-compose.tls.yml
  -f docker-compose.ghcr.yml
)

log() { echo "[update] $*"; }

cd "${REPO_DIR}"

# 1. compose 파일 등 배포 구성 변경분을 먼저 받아옵니다.
log "저장소 갱신"
git fetch -q origin dev
git reset -q --hard origin/dev

# 2. 교체 전 컨테이너 ID 기록
#    docker compose images 는 "실행 중인 컨테이너의" 이미지를 돌려주므로
#    pull 전후를 비교해도 값이 같습니다. 컨테이너 재생성 여부로 판단합니다.
BEFORE_CID="$(docker compose "${COMPOSE_FILES[@]}" ps -q app 2>/dev/null || true)"

# 3. 최신 이미지 받기
log "이미지 확인"
docker compose "${COMPOSE_FILES[@]}" pull -q app

# 4. 적용 (이미지나 설정이 바뀐 경우에만 compose 가 컨테이너를 재생성합니다)
docker compose "${COMPOSE_FILES[@]}" up -d --no-deps app

AFTER_CID="$(docker compose "${COMPOSE_FILES[@]}" ps -q app 2>/dev/null || true)"

if [ "${BEFORE_CID}" = "${AFTER_CID}" ]; then
  log "변경 없음 - 컨테이너를 그대로 유지합니다."
  exit 0
fi

log "컨테이너 교체됨: ${BEFORE_CID:0:12} → ${AFTER_CID:0:12}"

# 5. 기동 확인
for i in $(seq 1 30); do
  if curl -fsS -o /dev/null --max-time 5 http://localhost:8080/login 2>/dev/null \
     || docker compose "${COMPOSE_FILES[@]}" exec -T app curl -fsS -o /dev/null --max-time 5 http://localhost:8080/login 2>/dev/null; then
    log "기동 확인 완료"
    break
  fi
  sleep 5
done

# 6. 쓰지 않는 이미지 정리 (디스크 20GB 뿐이므로 필요합니다)
log "미사용 이미지 정리"
docker image prune -f > /dev/null

log "완료"
