# AWS EC2 배포 가이드

BuildiFy WMS 를 AWS EC2 한 대에 Docker 로 올리는 절차입니다.
앱(Tomcat 9)과 MySQL 을 같은 인스턴스에서 컨테이너로 함께 실행합니다.

---

## ⚠️ 먼저 확인할 것 — 요금

AWS 프리티어는 계정 생성 시점에 따라 방식이 다릅니다. **둘 다 "가입일 기준"이라
사용하지 않고 묵혀둬도 기간은 흘러갑니다.**

| 계정 생성 시점 | 방식 |
|---|---|
| 2025년 7월 15일 **이전** | 기존 프리티어 — t2.micro 750시간/월, **가입일로부터 12개월** |
| 2025년 7월 15일 **이후** | 크레딧 방식 — $100(+ 온보딩 과제 완료 시 최대 $200), 만료일 있음 |

**확인 방법**

- 콘솔 → **과금 정보 및 비용 관리** → **크레딧** : 크레딧 잔액과 만료일
- 같은 메뉴 → **청구서** → 기간 드롭다운에서 **가장 오래된 월** ≈ 계정 생성 시점

둘 다 해당 없다면(크레딧 $0 + 가입 후 12개월 경과) **첫 시간부터 정상 요금**이 부과됩니다.

**서울 리전 t3.micro 기준 대략적인 비용**

| 운영 방식 | 월 예상 |
|---|---|
| 24시간 상시 가동 | $9 ~ 12 (인스턴스 + EBS 20GiB) |
| 필요할 때만 켜기 | $2 내외 (중지 중에는 EBS 요금만) |

정확한 단가는 [EC2 온디맨드 요금](https://aws.amazon.com/ko/ec2/pricing/on-demand/)에서 서울 리전으로 확인하세요.

> 💡 **인스턴스를 중지(Stop)하면 인스턴스 요금은 발생하지 않습니다.**
> 포트폴리오 시연용이라면 평소엔 꺼두고 필요할 때만 켜는 방식이 합리적입니다.
> 켜고 2~3분이면 컨테이너가 자동으로 다시 올라옵니다 (`restart: unless-stopped`).

> ⚠️ **결제 알림을 먼저 설정하세요.** 아래 7단계 참고.

---

## 1. EC2 인스턴스 생성

AWS 콘솔 → 리전을 **아시아 태평양(서울) ap-northeast-2** 로 변경 → **EC2** 검색 → **인스턴스 시작**

| 항목 | 설정값 |
|------|--------|
| 이름 | `buildify-wms` |
| AMI | **Amazon Linux 2023** |
| 인스턴스 유형 | **t3.micro** |
| 키 페어 | **새 키 페어 생성** → 이름 `buildify-key`, 유형 RSA, 형식 `.pem` → 다운로드 |
| 네트워크 설정 | 아래 2번 참고 |
| 스토리지 | gp3 **20GiB** (기본 8GiB 는 Docker 이미지에 빠듯합니다) |

> 💡 다운로드한 `.pem` 파일은 **다시 받을 수 없습니다.** 안전한 곳에 보관하세요.
>
> 💡 메모리가 부족하면 나중에 인스턴스를 중지하고 유형만 t3.small 로 바꿀 수 있습니다.
> 데이터는 그대로 유지되니 t3.micro 로 시작해도 됩니다.

## 2. 보안 그룹 (방화벽)

인스턴스 생성 화면의 "네트워크 설정 → 편집" 에서 규칙을 다음과 같이 설정합니다.
NCP 의 ACG 와 같은 개념입니다.

| 유형 | 포트 | 소스 | 용도 |
|------|------|------|------|
| SSH | 22 | **내 IP** | 서버 접속 |
| HTTP | 80 | Anywhere (0.0.0.0/0) | 웹 접속 |

> 🔒 **3306(MySQL)은 절대 열지 마세요.** DB 는 컨테이너 내부에서만 통신하며,
> 호스트에도 `127.0.0.1` 로만 바인딩되어 외부에서 접근할 수 없습니다.

## 3. SSH 접속

```bash
chmod 400 ~/Downloads/buildify-key.pem
ssh -i ~/Downloads/buildify-key.pem ec2-user@<퍼블릭-IPv4-주소>
```

퍼블릭 IP 는 EC2 콘솔의 인스턴스 상세 화면에서 확인합니다.

> 인스턴스를 중지했다 켜면 퍼블릭 IP 가 바뀝니다.
> 고정이 필요하면 **탄력적 IP(Elastic IP)** 를 할당해 연결하세요. (NCP 공인 IP 와 동일 개념)

## 4. 서버 초기 세팅

접속한 서버에서 실행합니다. 스왑 4GB, Docker, Compose, buildx 를 한 번에 설치합니다.

```bash
sudo dnf install -y git          # Amazon Linux 2023 에는 git 이 기본 설치되어 있지 않습니다
git clone https://github.com/seonmin12/Buildify_Phase-2.git buildify
cd buildify
git checkout deploy/docker
bash docker/aws/setup-ec2.sh
```

**끝나면 반드시 재접속합니다.** docker 그룹 권한은 재로그인해야 적용됩니다.

```bash
exit
ssh -i ~/Downloads/buildify-key.pem ec2-user@<퍼블릭-IP>
cd buildify
docker version && docker compose version    # 확인
```

## 5. 배포

```bash
cp .env.example .env
vi .env
```

`.env` 에서 최소한 아래 세 가지를 채웁니다. **비밀번호는 로컬에서 쓰던 것과 다른 값**으로 새로 만드세요.

```properties
DB_USERNAME=buildify
DB_PASSWORD=<충분히 긴 임의의 문자열>
MYSQL_ROOT_PASSWORD=<위와 다른 임의의 문자열>
APP_PORT=80
```

> 비밀번호 생성이 귀찮으면: `openssl rand -base64 24`

실행합니다.

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

첫 실행은 Gradle 의존성 다운로드와 이미지 빌드 때문에 **10~20분 정도** 걸립니다.
메모리가 작아 스왑을 쓰므로 느린 것이 정상입니다.

## 6. 확인

```bash
docker compose ps                  # 두 컨테이너가 모두 Up 인지
docker compose logs -f app         # "Server startup in ..." 이 보이면 성공
curl -I http://localhost/login     # 302 또는 200
```

브라우저에서 `http://<퍼블릭-IP>` 로 접속합니다.

| 구분 | 계정 | 비밀번호 |
|------|------|----------|
| 관리자 | `admin01` | `admin1234!` |
| 사용자 | `user01` ~ `user20` | `user1234!` |

> ⚠️ 데모 계정은 공개 서버에 그대로 노출됩니다. 포트폴리오 시연 목적이라면 괜찮지만,
> 그 외의 용도라면 비밀번호를 바꾸고 시드 계정을 정리하세요.

## 7. 결제 알림 설정 (꼭 하세요)

콘솔 → **Billing and Cost Management** → **Budgets** → 예산 생성

- 유형: **비용 예산**
- 금액: 월 **$5** 정도
- 알림: 실제 비용이 예산의 **80%** 도달 시 이메일

---

## 운영 명령어

```bash
# 로그 보기
docker compose logs -f app
docker compose logs -f mysql

# 코드 갱신 후 재배포 (DB 데이터는 유지됩니다)
git pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# 중지 / 재시작
docker compose stop
docker compose start

# DB 를 포함해 완전히 초기화 (시드 데이터 다시 적재)
docker compose down -v
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# 리소스 사용량 확인
docker stats --no-stream
free -h
```

## 문제 해결

**빌드 도중 멈추거나 컨테이너가 죽는다 (OOM)**

```bash
free -h                 # 스왑이 잡혀 있는지 확인
dmesg | grep -i "killed process"
```

스왑이 없다면 `bash docker/aws/setup-ec2.sh` 를 다시 실행하세요.
그래도 부족하면 인스턴스를 중지하고 유형을 **t3.small(RAM 2GB)** 로 변경합니다.
(EC2 콘솔 → 인스턴스 중지 → 작업 → 인스턴스 설정 → 인스턴스 유형 변경 → 시작)

**서버에서 빌드가 너무 느리다**

로컬에서 이미지를 만들어 전송하는 방법도 있습니다.

```bash
# 로컬 (Apple Silicon 이면 플랫폼을 맞춰야 합니다)
docker build --platform linux/amd64 -t buildify-wms:latest .
docker save buildify-wms:latest | gzip > buildify-wms.tar.gz
scp -i ~/Downloads/buildify-key.pem buildify-wms.tar.gz ec2-user@<퍼블릭-IP>:~

# 서버
gunzip -c buildify-wms.tar.gz | docker load
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d   # --build 없이
```

**브라우저에서 접속이 안 된다**

1. 보안 그룹에 HTTP 80 인바운드 규칙이 있는지 확인
2. `.env` 에 `APP_PORT=80` 이 있는지 확인
3. `docker compose ps` 로 app 컨테이너 포트가 `0.0.0.0:80->8080/tcp` 인지 확인

**MySQL 초기화 스크립트가 반영되지 않는다**

초기화 스크립트는 **데이터 볼륨이 비어 있을 때 최초 1회만** 실행됩니다.
`docker compose down -v` 로 볼륨을 지우고 다시 올리세요.

---

## 다음 단계

- **도메인 + HTTPS** → [docs/DOMAIN-HTTPS.md](DOMAIN-HTTPS.md)
  탄력적 IP 없이 도메인을 고정하는 방법(부팅 시 Cloudflare DNS 자동 갱신)과
  HTTPS 적용 절차를 다룹니다.
- **RDS 분리** → DB 를 관리형으로 옮기고 `.env` 의 `DB_URL` 만 교체 (앱 수정 불필요)
- **GitHub Actions** → 푸시하면 이미지를 빌드해 서버에서 pull 하도록 자동화
