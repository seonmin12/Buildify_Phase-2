# 도메인 연결 및 HTTPS 적용 가이드

`buildify-wms.co.kr` 을 EC2 인스턴스에 연결하고 HTTPS 를 적용하는 절차입니다.

## 왜 이런 구조인가

EC2 인스턴스를 중지했다 켜면 **퍼블릭 IP 가 바뀝니다.** 탄력적 IP(Elastic IP)를 붙이면
고정되지만, 2024년 2월부터 공인 IPv4 는 **인스턴스를 꺼놓아도 시간당 요금**이 부과됩니다
(약 월 $3.6). 평소에 꺼두는 데모 서버에는 부담입니다.

그래서 **부팅할 때마다 서버가 스스로 현재 IP 를 Cloudflare DNS 에 등록**하도록 했습니다.
탄력적 IP 없이 도메인이 항상 올바른 곳을 가리키고, 추가 비용은 없습니다.

```
인스턴스 시작
  → systemd(buildify-ddns.service) 자동 실행
  → EC2 메타데이터에서 현재 공인 IP 조회
  → Cloudflare API 로 A 레코드 갱신 (TTL 60초)
  → 약 1~2분 후 도메인으로 접속 가능
```

---

## 1. Cloudflare 에 도메인 등록

1. <https://dash.cloudflare.com> 가입 (무료 플랜)
2. **Add a site** → `buildify-wms.co.kr` 입력 → **Free** 플랜 선택
3. Cloudflare 가 배정한 네임서버 2개를 보여줍니다. 예:
   ```
   xxx.ns.cloudflare.com
   yyy.ns.cloudflare.com
   ```
   이 값을 메모해 둡니다.

## 2. 가비아에서 네임서버 변경

가비아 → **도메인 관리 → 전체 도메인 → 도메인 상세 → 네임서버/DNS호스트/DNSSEC**
→ **네임 서버 설정**

| 순위 | 변경 전 (가비아 기본) | 변경 후 |
|------|----------------------|---------|
| 1차 | ns.gabia.co.kr | `xxx.ns.cloudflare.com` |
| 2차 | ns1.gabia.co.kr | `yyy.ns.cloudflare.com` |
| 3차 | ns.gabia.net | (비움) |

저장 후 전파까지 **수 분 ~ 최대 24시간**이 걸립니다.
Cloudflare 대시보드에서 상태가 **Active** 로 바뀌면 완료입니다.

```bash
# 전파 확인
dig NS buildify-wms.co.kr +short
```

## 3. Cloudflare API 토큰 발급

Cloudflare 대시보드 → 우측 상단 프로필 → **My Profile → API Tokens**
→ **Create Token** → **Edit zone DNS** 템플릿 사용

| 항목 | 값 |
|------|-----|
| Permissions | Zone — DNS — **Edit** |
| Zone Resources | Include — Specific zone — `buildify-wms.co.kr` |

생성된 토큰은 **한 번만 표시**되니 바로 복사해 둡니다.

**Zone ID** 도 필요합니다. 도메인 개요(Overview) 페이지 우측 하단 **API** 영역에 있습니다.

> 🔒 토큰은 저장소에 커밋하지 않습니다. 서버의 `/etc/buildify-ddns.env` 에만 둡니다.

## 4. EC2 에 DNS 자동 갱신 설치

인스턴스를 시작하고 SSH 접속한 뒤:

```bash
cd ~/buildify
git pull

# 스크립트 설치
sudo cp docker/aws/cloudflare-ddns.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/cloudflare-ddns.sh
sudo cp docker/aws/buildify-ddns.service /etc/systemd/system/
```

설정 파일을 만듭니다. **토큰이 셸 히스토리에 남지 않도록** 편집기로 직접 입력하세요.

```bash
sudo touch /etc/buildify-ddns.env
sudo chmod 600 /etc/buildify-ddns.env
sudo vi /etc/buildify-ddns.env
```

```properties
CF_API_TOKEN=여기에_토큰
CF_ZONE_ID=여기에_Zone_ID
CF_RECORD_NAME=buildify-wms.co.kr
CF_PROXIED=true
```

등록하고 바로 실행합니다.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now buildify-ddns.service
sudo systemctl status buildify-ddns.service --no-pager
```

`A 레코드 갱신: ... → 43.x.x.x` 또는 `생성 완료` 가 보이면 성공입니다.
이후로는 **인스턴스를 켤 때마다 자동으로 실행**됩니다.

## 5. HTTPS 적용

Cloudflare 프록시(주황 구름)를 켜면 **Cloudflare 가 HTTPS 를 대신 처리**합니다.
서버에 인증서를 설치하거나 갱신할 필요가 없습니다.

### 5-1. 우선 동작시키기 (Flexible)

Cloudflare 대시보드 → **SSL/TLS → Overview** → 암호화 모드 **Flexible**

이 상태로 `https://buildify-wms.co.kr` 이 바로 열립니다.

> ⚠️ **Flexible 은 Cloudflare ↔ 원본 서버 구간이 평문(HTTP)입니다.**
> 로그인 정보가 그 구간을 평문으로 지나가므로, 데모 이상의 용도라면
> 아래 5-2 로 반드시 올리세요.

### 5-2. 권장 최종 상태 (Full strict)

원본 서버에도 TLS 를 적용해 전 구간을 암호화합니다.

1. Cloudflare → **SSL/TLS → Origin Server → Create Certificate**
   → 유효기간 15년짜리 인증서와 키를 발급 (무료, 갱신 불필요)
2. 서버 앞단에 리버스 프록시(Caddy 또는 Nginx)를 두고 443 에서 그 인증서로 TLS 종료
3. 보안 그룹에 **443** 인바운드 추가
4. Cloudflare 암호화 모드를 **Full (strict)** 로 변경

> 이 단계는 컨테이너 구성이 하나 늘어납니다. 필요할 때 `docker-compose.prod.yml` 에
> 리버스 프록시 서비스를 추가하면 됩니다.

### 5-3. 권장 추가 설정

Cloudflare 대시보드에서:

- **SSL/TLS → Edge Certificates → Always Use HTTPS**: 켜기 (HTTP 접속을 HTTPS 로 리다이렉트)
- **Speed → Auto Minify**: 정적 자원 최적화 (선택)

---

## 확인

```bash
dig A buildify-wms.co.kr +short          # Cloudflare 프록시 IP 가 나옵니다 (원본 IP 아님)
curl -I https://buildify-wms.co.kr/login # 200
```

## 문제 해결

**도메인은 열리는데 502/521 이 뜬다**

원본 서버가 죽어 있거나 80 포트가 막힌 경우입니다.

```bash
docker compose ps
curl -I http://localhost/login
```

보안 그룹에 HTTP 80 인바운드 규칙이 있는지도 확인하세요.

**인스턴스를 켰는데 도메인이 예전 IP 를 가리킨다**

```bash
sudo systemctl status buildify-ddns.service --no-pager
sudo /usr/local/bin/cloudflare-ddns.sh      # 수동 실행해서 로그 확인
```

TTL 이 60초라 갱신 후 1~2분이면 반영됩니다.

**`dig NS` 가 아직 가비아를 가리킨다**

네임서버 전파가 끝나지 않았습니다. 최대 24시간까지 걸릴 수 있습니다.
