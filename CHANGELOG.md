# CHANGELOG.md — memorygod 변경 이력

> 모든 기능 추가·변경·삭제는 이 파일에 기록한다.
> 형식: [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/) 참고
> 버전: [Semantic Versioning](https://semver.org/lang/ko/) 준수

---

## [미출시] — 개발 중

### 추가 예정
- MVP v1.0.0 전체 기능 (FEATURES.md 참고)
- v1.1.0 라이브러리 기능 (FEATURES.md `## v1.1.0` 섹션 참고)
- v1.2.0 세트 ON/OFF 기능 (FEATURES.md `## v1.2.0` 섹션 참고)

---

## [1.2.0] — 미출시 (세트 ON/OFF)

### 변경
- 세트 활성화 방식: 1개 제한 → 다중 ON/OFF 토글로 전면 교체 (SETS-05 → SETS-07~10)
- 학습 큐 생성: 단일 세트 → ON 상태인 모든 세트 합산으로 변경

### 추가
- 내 세트 / 공유받은 세트 각각 ON/OFF 토글 스위치 UI
- 세트 목록 상단 "학습 중 N개 · 총 M장" 요약
- 마지막 ON 세트 OFF 방지 안전장치

### DB 변경
- `card_sets` 테이블: `is_enabled` 컬럼 추가
- `shared_sets.is_active` 컬럼: 1개 제한 의미 → 다중 허용으로 변경
- 마이그레이션 파일: `003_set_toggle.sql`

---

## [1.1.0] — 미출시 (라이브러리)

### 추가
- 라이브러리 페이지: 공개 세트 목록 + 검색 + 정렬 + 도메인 필터 (LIB-01, LIB-02, LIB-09, LIB-10)
- 세트 공개 등록 / 취소 버튼 (LIB-04, LIB-05)
- 세트 상세 미리보기 + 가져오기 (LIB-03, LIB-08)
- 별점 평가 1~5점, 1인 1회, 평균 표시 (LIB-06, LIB-07)
- StarRating.svelte, LibraryCard.svelte 컴포넌트
- 네비게이션에 라이브러리 탭 추가

### DB 변경
- `card_sets` 테이블: `is_public`, `source_set_id`, `download_count`, `author_name` 컬럼 추가
- `library_ratings` 테이블 신규 생성
- `increment_download_count` RPC 함수 추가
- 마이그레이션 파일: `002_library.sql`

### CLAUDE.md 변경
- 금지 사항: "마켓플레이스(크리에이터 공개 판매)" → "마켓플레이스(크리에이터 유료 판매/결제 기반 공유)"로 범위 명확화

---

## [1.0.0] — 미출시 (MVP)

### 추가
- 이메일/패스워드 인증 (로그인·회원가입·로그아웃)
- 엑셀(.xlsx) / CSV 업로드 → 플래시카드 파싱·저장
- SM-2 알고리즘 기반 간격 반복 학습
- 플래시카드 플립 애니메이션 (모바일 + 데스크탑 2열)
- 3단계 힌트 시스템
- 오늘의 학습 큐 (복습 카드 + 신규 카드)
- 세트 공유 코드 (MG-XXXX 형식)
- 홈 대시보드 (진행률·D-day·미니 통계)
- 주간 통계 차트 + 스트릭 캘린더
- 설정 (D-day·학습량·알림 시간·수면 보호)
- OneSignal 웹 푸시 알림
- PWA 설치 지원
- 오프라인 학습 (Service Worker 캐시)
- GitHub Pages 자동 배포 (GitHub Actions)

---

<!-- 
새 기능이 추가될 때마다 아래 형식으로 항목을 추가한다.

## [1.1.0] — YYYY-MM-DD

### 추가
- 기능 설명 (관련 ID: FEATURES.md의 ID)

### 변경
- 기존 기능 수정 내용

### 수정
- 버그 수정 내용

### 제거
- 삭제된 기능
-->
