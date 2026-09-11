#!/usr/bin/env bash
# =====================================================================
# EC2(Amazon Linux 2023) 최초 1회 세팅 스크립트
#
#   curl -fsSL https://raw.githubusercontent.com/seonmin12/Buildify_Phase-2/deploy/docker/docker/aws/setup-ec2.sh | bash
#   또는 저장소를 clone 한 뒤: bash docker/aws/setup-ec2.sh
#
# 하는 일
#   1. 스왑 4GB 생성  (t3.micro 는 RAM 1GB 뿐이라 Gradle 빌드/Tomcat 구동에 필수)
#   2. Docker 설치 및 부팅 시 자동 시작 등록
#   3. Docker Compose · buildx 플러그인 설치
#
# 실행 후에는 반드시 재접속(exit 후 다시 ssh)해야 docker 명령을 sudo 없이 쓸 수 있습니다.
# =====================================================================
set -euo pipefail

SWAP_SIZE_GB="${SWAP_SIZE_GB:-4}"
SWAP_FILE="/swapfile"
COMPOSE_FALLBACK_VERSION="v2.32.4"
BUILDX_FALLBACK_VERSION="v0.19.3"
CLI_PLUGIN_DIR="/usr/local/lib/docker/cli-plugins"
ARCH="$(uname -m)"                                   # x86_64 또는 aarch64
ARCH_ALT="$([ "$(uname -m)" = "aarch64" ] && echo arm64 || echo amd64)"

log() { echo -e "\n\033[1;32m==>\033[0m $*"; }

# ---------------------------------------------------------------------
log "1/3 스왑 ${SWAP_SIZE_GB}GB 설정"
# ---------------------------------------------------------------------
if swapon --show | grep -q "${SWAP_FILE}"; then
  echo "이미 스왑이 활성화되어 있습니다. 건너뜁니다."
else
  sudo fallocate -l "${SWAP_SIZE_GB}G" "${SWAP_FILE}" 2>/dev/null \
    || sudo dd if=/dev/zero of="${SWAP_FILE}" bs=1M count=$((SWAP_SIZE_GB * 1024)) status=progress
  sudo chmod 600 "${SWAP_FILE}"
  sudo mkswap "${SWAP_FILE}"
  sudo swapon "${SWAP_FILE}"

  # 재부팅 후에도 유지되도록 fstab 에 등록
  if ! grep -q "^${SWAP_FILE}" /etc/fstab; then
    echo "${SWAP_FILE} none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
  fi

  # 메모리가 작으므로 스왑을 적극적으로 쓰도록 설정
  echo 'vm.swappiness=60' | sudo tee /etc/sysctl.d/99-swappiness.conf > /dev/null
  sudo sysctl -p /etc/sysctl.d/99-swappiness.conf > /dev/null
fi
free -h

# ---------------------------------------------------------------------
log "2/3 git · Docker 설치"
# ---------------------------------------------------------------------
if ! command -v git > /dev/null 2>&1; then
  sudo dnf install -y git
fi

if command -v docker > /dev/null 2>&1; then
  echo "Docker 가 이미 설치되어 있습니다: $(docker --version)"
else
  sudo dnf install -y docker
fi
sudo systemctl enable --now docker
sudo usermod -aG docker "$(whoami)"

# ---------------------------------------------------------------------
log "3/3 Docker Compose · buildx 플러그인 설치"
# ---------------------------------------------------------------------
if docker compose version > /dev/null 2>&1; then
  echo "Compose 가 이미 설치되어 있습니다: $(docker compose version --short)"
else
  # 최신 버전을 조회하되, 실패하면 검증된 버전으로 대체합니다.
  COMPOSE_VERSION="$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest 2>/dev/null \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  COMPOSE_VERSION="${COMPOSE_VERSION:-$COMPOSE_FALLBACK_VERSION}"
  echo "설치할 Compose 버전: ${COMPOSE_VERSION}"

  sudo mkdir -p "${CLI_PLUGIN_DIR}"
  sudo curl -fsSL \
    "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${ARCH}" \
    -o "${CLI_PLUGIN_DIR}/docker-compose"
  sudo chmod +x "${CLI_PLUGIN_DIR}/docker-compose"
fi

# buildx 는 Compose 의 `--build` 에 필요하지만 Amazon Linux 의 docker 패키지에
# 포함되어 있지 않아 별도로 설치합니다. (없으면 "requires buildx 0.17.0 or later" 오류)
# Amazon Linux 의 docker 패키지에 buildx 가 포함되는 경우가 있으나 버전이 낮아
# Compose 가 요구하는 0.17.0 을 만족하지 못할 수 있습니다. 버전까지 확인합니다.
BUILDX_MIN="0.17.0"
BUILDX_CURRENT="$(docker buildx version 2>/dev/null | sed -n 's/.*v\{0,1\}\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*/\1/p' | head -1)"
if [ -n "${BUILDX_CURRENT}" ] \
   && [ "$(printf '%s\n' "${BUILDX_MIN}" "${BUILDX_CURRENT}" | sort -V | head -1)" = "${BUILDX_MIN}" ]; then
  echo "buildx ${BUILDX_CURRENT} 가 이미 설치되어 있습니다 (최소 ${BUILDX_MIN} 충족)"
else
  if [ -n "${BUILDX_CURRENT}" ]; then
    echo "buildx ${BUILDX_CURRENT} 는 최소 요구 버전(${BUILDX_MIN})보다 낮아 최신 버전으로 교체합니다."
  fi
  BUILDX_VERSION="$(curl -fsSL https://api.github.com/repos/docker/buildx/releases/latest 2>/dev/null \
    | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  BUILDX_VERSION="${BUILDX_VERSION:-$BUILDX_FALLBACK_VERSION}"
  echo "설치할 buildx 버전: ${BUILDX_VERSION}"

  sudo mkdir -p "${CLI_PLUGIN_DIR}"
  sudo curl -fsSL \
    "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-${ARCH_ALT}" \
    -o "${CLI_PLUGIN_DIR}/docker-buildx"
  sudo chmod +x "${CLI_PLUGIN_DIR}/docker-buildx"
fi

# ---------------------------------------------------------------------
log "완료"
# ---------------------------------------------------------------------
cat <<'EOF'

다음 단계:
  1) exit 로 로그아웃한 뒤 다시 ssh 접속하세요.
     (docker 그룹 권한은 재로그인해야 적용됩니다)
  2) 재접속 후 확인:
       docker version
       docker compose version
  3) 저장소를 clone 하고 .env 를 만든 뒤 배포:
       cp .env.example .env && vi .env
       docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

EOF
