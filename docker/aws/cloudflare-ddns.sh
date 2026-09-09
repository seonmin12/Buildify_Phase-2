#!/usr/bin/env bash
# =====================================================================
# EC2 의 현재 공인 IP 를 Cloudflare DNS A 레코드에 반영합니다.
#
# 인스턴스를 중지했다 켜면 퍼블릭 IP 가 바뀌는데, 탄력적 IP 를 붙이면
# 꺼놓은 동안에도 요금이 나옵니다. 대신 부팅할 때마다 이 스크립트가
# 현재 IP 를 DNS 에 등록하도록 해서 비용 없이 도메인을 고정합니다.
#
# 설정 파일: /etc/buildify-ddns.env  (권한 600)
#   CF_API_TOKEN=...        Cloudflare API 토큰 (Zone:DNS:Edit 권한)
#   CF_ZONE_ID=...          Cloudflare 대시보드 우측 하단의 Zone ID
#   CF_RECORD_NAME=...      예: buildify-wms.co.kr
#   CF_PROXIED=true         Cloudflare 프록시(주황 구름) 사용 여부
#
# 수동 실행: sudo /usr/local/bin/cloudflare-ddns.sh
# =====================================================================
set -euo pipefail

CONFIG_FILE="${CONFIG_FILE:-/etc/buildify-ddns.env}"
API="https://api.cloudflare.com/client/v4"

log() { echo "[ddns] $*"; }

if [ ! -r "${CONFIG_FILE}" ]; then
  echo "[ddns] 설정 파일을 읽을 수 없습니다: ${CONFIG_FILE}" >&2
  exit 1
fi
# shellcheck disable=SC1090
. "${CONFIG_FILE}"

: "${CF_API_TOKEN:?CF_API_TOKEN 이 설정 파일에 없습니다}"
: "${CF_ZONE_ID:?CF_ZONE_ID 가 설정 파일에 없습니다}"
: "${CF_RECORD_NAME:?CF_RECORD_NAME 이 설정 파일에 없습니다}"
CF_PROXIED="${CF_PROXIED:-true}"

# ---------------------------------------------------------------------
# 1. 현재 공인 IP 조회 (EC2 메타데이터 IMDSv2, 실패 시 외부 서비스로 대체)
# ---------------------------------------------------------------------
PUBLIC_IP=""
IMDS_TOKEN="$(curl -fsS --max-time 3 -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null || true)"
if [ -n "${IMDS_TOKEN}" ]; then
  PUBLIC_IP="$(curl -fsS --max-time 3 \
    -H "X-aws-ec2-metadata-token: ${IMDS_TOKEN}" \
    "http://169.254.169.254/latest/meta-data/public-ipv4" 2>/dev/null || true)"
fi
if [ -z "${PUBLIC_IP}" ]; then
  log "EC2 메타데이터 조회 실패 - 외부 서비스로 IP 를 확인합니다."
  PUBLIC_IP="$(curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null || true)"
fi
if ! echo "${PUBLIC_IP}" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "[ddns] 공인 IP 를 확인하지 못했습니다: '${PUBLIC_IP}'" >&2
  exit 1
fi
log "현재 공인 IP: ${PUBLIC_IP}"

cf() { curl -fsS -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" "$@"; }

# ---------------------------------------------------------------------
# 2. 기존 A 레코드 조회
# ---------------------------------------------------------------------
RECORD_JSON="$(cf "${API}/zones/${CF_ZONE_ID}/dns_records?type=A&name=${CF_RECORD_NAME}")"
RECORD_ID="$(echo "${RECORD_JSON}"  | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -1)"
CURRENT_IP="$(echo "${RECORD_JSON}" | sed -n 's/.*"content":"\([^"]*\)".*/\1/p' | head -1)"

BODY="{\"type\":\"A\",\"name\":\"${CF_RECORD_NAME}\",\"content\":\"${PUBLIC_IP}\",\"ttl\":60,\"proxied\":${CF_PROXIED}}"

# ---------------------------------------------------------------------
# 3. 생성 또는 갱신 (변경이 없으면 호출하지 않음)
# ---------------------------------------------------------------------
if [ -z "${RECORD_ID}" ]; then
  log "A 레코드가 없어 새로 생성합니다: ${CF_RECORD_NAME} → ${PUBLIC_IP}"
  cf -X POST "${API}/zones/${CF_ZONE_ID}/dns_records" --data "${BODY}" > /dev/null
  log "생성 완료"
elif [ "${CURRENT_IP}" = "${PUBLIC_IP}" ]; then
  log "IP 변경 없음 (${CURRENT_IP}) - 갱신을 건너뜁니다."
else
  log "A 레코드 갱신: ${CURRENT_IP} → ${PUBLIC_IP}"
  cf -X PUT "${API}/zones/${CF_ZONE_ID}/dns_records/${RECORD_ID}" --data "${BODY}" > /dev/null
  log "갱신 완료"
fi
