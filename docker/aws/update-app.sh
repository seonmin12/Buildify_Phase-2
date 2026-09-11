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

# 2. 교체 전 이미지 다이제스트 기록
BEFORE="$(docker compose "${COMPOSE_FILES[@]}" images -q app 2>/dev/null || true)"

# 3. 최신 이미지 받기
log "이미지 확인"
docker compose "${COMPOSE_FILES[@]}" pull -q app

AFTER="$(docker compose "${COMPOSE_FILES[@]}" images -q app 2>/dev/null || true)"

if [ -n "${BEFORE}" ] && [ "${BEFORE}" = "${AFTER}" ]; then
  log "변경 없음 - 교체를 건너뜁니다."
  exit 0
fi

# 4. 교체 (mysql·caddy 는 그대로 두고 app 만 재생성)
log "새 이미지로 교체: ${BEFORE:0:12} → ${AFTER:0:12}"
docker compose "${COMPOSE_FILES[@]}" up -d --no-deps app

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
