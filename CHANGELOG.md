# CHANGELOG.md — memorygod 변경 이력

> 모든 기능 추가·변경·삭제는 이 파일에 기록한다.
> 형식: [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/) 참고
> 버전: [Semantic Versioning](https://semver.org/lang/ko/) 준수

---

## [1.0.0] — 2026-04-03 (MVP)

### 추가
- 이메일/패스워드 인증 (AUTH-01~04): 로그인·회원가입·로그아웃·세션 유지
- 엑셀/CSV 업로드 (UPLOAD-01~04): SheetJS 기반 파싱, 컬럼 별칭 처리, 미리보기
- 플래시카드 학습 (STUDY-01~08): SM-2 알고리즘, 플립 애니메이션, 3단계 힌트, 데스크탑 2열 레이아웃
- 세트 관리 (SETS-01~06): 목록·상세·공유코드·참여·활성화·영역 필터
- 홈 대시보드 (HOME-01~04): 복습 배너, 진행률+숙달도, D-day 뱃지, 미니 통계
- 통계 (STATS-01~04): 주간 바 차트, 영역별 숙달도, 스트릭 캘린더, 진행률
- 설정 (SETTINGS-01~06): D-day, 학습량 슬라이더, 카드 순서, 알림·수면 시간
- OneSignal 푸시 알림 (NOTIFY-01,03): SDK 초기화, user_id 연결
- PWA (PWA-01~03): manifest, maskable 아이콘, Service Worker 오프라인 캐시
- DB 스키마 (DB-01~02): 6개 테이블 + RLS + increment_daily_stats RPC
- GitHub Pages 자동 배포 (GitHub Actions)
- 샘플 엑셀 6종 (영단어, 한문, 한국사, 양자역학, 천문학, 기술사)

### 기술 스택
- Svelte 5 + SvelteKit 2 (adapter-static)
- Tailwind CSS v4
- Supabase (PostgreSQL + RLS + Auth)
- vite-plugin-pwa / @vite-pwa/sveltekit
- SheetJS (xlsx)

---

<!--
## [1.1.0] — YYYY-MM-DD

### 추가
- 기능 설명 (관련 ID)

### 변경
- 기존 기능 수정

### 수정
- 버그 수정

### 제거
- 삭제된 기능
-->
