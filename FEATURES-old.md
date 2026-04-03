# FEATURES.md — memorygod 기능 명세 및 변경 이력

> Claude Code는 새 기능 추가 전 반드시 이 파일을 읽는다.
> 기능이 확정되면 이 파일에 추가하고, CHANGELOG.md에도 기록한다.

---

## 이 파일의 사용법

### 기능 추가 요청이 들어올 때 Claude Code가 할 일
1. `## 확정 기능 목록`에서 해당 기능이 이미 있는지 확인
2. 없으면 `## 대기 중` 섹션에서 찾기
3. 기능 구현 후 → `확정 기능 목록`으로 이동 + `상태: 완료`로 업데이트
4. CHANGELOG.md에 버전 항목 추가

### 상태 코드
| 상태 | 의미 |
|------|------|
| `🟡 대기` | 논의됐지만 구현 미시작 |
| `🔵 진행` | 현재 구현 중 |
| `🟢 완료` | 구현 및 배포 완료 |
| `🔴 보류` | 일시 중단 또는 재검토 필요 |
| `⚫ 취소` | MVP 범위 외로 제외 |

---

## v1.0.0 — MVP 확정 기능 목록

### AUTH — 인증
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| AUTH-01 | 이메일/패스워드 회원가입 | 🟢 완료 | `src/routes/auth/register/+page.svelte` |
| AUTH-02 | 이메일/패스워드 로그인 | 🟢 완료 | `src/routes/auth/login/+page.svelte` |
| AUTH-03 | 로그아웃 | 🟢 완료 | `src/routes/settings/+page.svelte` |
| AUTH-04 | 세션 유지 (Supabase Auth) | 🟢 완료 | `src/lib/auth.ts`, `src/routes/+layout.svelte` |

### UPLOAD — 카드 업로드
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| UPLOAD-01 | 엑셀(.xlsx) 파싱 및 카드 저장 | 🟢 완료 | `src/routes/upload/+page.svelte`, `src/lib/xlsx.ts` |
| UPLOAD-02 | CSV 파싱 | 🟢 완료 | `src/lib/xlsx.ts` |
| UPLOAD-03 | 컬럼명 별칭 처리 (앞면/front/question 등) | 🟢 완료 | `src/lib/xlsx.ts` |
| UPLOAD-04 | 업로드 미리보기 + 배치 저장 | 🟢 완료 | `src/routes/upload/+page.svelte` |

### STUDY — 학습
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| STUDY-01 | 오늘의 카드 큐 생성 (복습 + 신규) | 🟢 완료 | `src/routes/study/+page.svelte` |
| STUDY-02 | 플래시카드 플립 애니메이션 | 🟢 완료 | `src/lib/components/FlashCard.svelte` |
| STUDY-03 | 3단계 힌트 (글자수→첫글자→앞절반) | 🟢 완료 | `src/lib/components/FlashCard.svelte` |
| STUDY-04 | 평가 버튼 3개 (알았음/헷갈림/몰랐음) | 🟢 완료 | `src/lib/components/FlashCard.svelte` |
| STUDY-05 | SM-2 알고리즘으로 다음 복습일 계산 | 🟢 완료 | `src/lib/sm2.ts` |
| STUDY-06 | 세션 완료 결과 요약 모달 | 🟢 완료 | `src/routes/study/+page.svelte` |
| STUDY-07 | 데스크탑 2열 레이아웃 | 🟢 완료 | `src/routes/study/+page.svelte` |
| STUDY-08 | 오프라인 학습 지원 (Service Worker 캐시) | 🟢 완료 | `vite.config.ts` (workbox) |

### SETS — 세트 관리
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| SETS-01 | 세트 목록 조회 | 🟢 완료 | `src/routes/sets/+page.svelte` |
| SETS-02 | 세트 상세 페이지 (카드 테이블뷰) | 🟢 완료 | `src/routes/sets/[id]/+page.svelte` |
| SETS-03 | 공유 코드 생성 (MG-XXXX 형식) | 🟢 완료 | `src/routes/sets/[id]/+page.svelte` |
| SETS-04 | 공유 코드로 세트 참여 | 🟢 완료 | `src/routes/sets/+page.svelte` |
| SETS-05 | 활성 세트 전환 (1개만 활성화) | 🟢 완료 | `src/routes/sets/+page.svelte` |
| SETS-06 | 영역(domain) 필터 | 🟢 완료 | `src/lib/components/DomainFilter.svelte`, `src/routes/sets/[id]/+page.svelte` |

### HOME — 홈 대시보드
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| HOME-01 | 오늘의 복습 배너 (복습N + 신규N) | 🟢 완료 | `src/routes/+page.svelte` |
| HOME-02 | 세트 목록 카드 (진행률 바 + 숙달도%) | 🟢 완료 | `src/routes/+page.svelte` |
| HOME-03 | D-day 뱃지 표시 | 🟢 완료 | `src/routes/+page.svelte` |
| HOME-04 | 통계 미니 (오늘학습/숙달도/연속일) | 🟢 완료 | `src/routes/+page.svelte` |

### STATS — 통계
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| STATS-01 | 주간 학습량 바 차트 (7일) | 🟢 완료 | `src/routes/stats/+page.svelte` |
| STATS-02 | 영역별 숙달도 게이지 바 | 🟢 완료 | `src/routes/stats/+page.svelte` |
| STATS-03 | 연속 학습 스트릭 캘린더 | 🟢 완료 | `src/lib/components/StreakCalendar.svelte` |
| STATS-04 | 전체/숙달 카드 수 + 진행률 | 🟢 완료 | `src/routes/stats/+page.svelte` |

### SETTINGS — 설정
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| SETTINGS-01 | D-day 날짜 선택 | 🟢 완료 | `src/routes/settings/+page.svelte` |
| SETTINGS-02 | 하루 새 카드 슬라이더 (5~100) | 🟢 완료 | `src/routes/settings/+page.svelte` |
| SETTINGS-03 | 하루 복습 한도 슬라이더 (10~200) | 🟢 완료 | `src/routes/settings/+page.svelte` |
| SETTINGS-04 | 카드 순서 설정 (순서대로/연관도순/영역선택) | 🟢 완료 | `src/routes/settings/+page.svelte` |
| SETTINGS-05 | 알림 시간 설정 (기본 07:30, 20:00) | 🟢 완료 | `src/routes/settings/+page.svelte` |
| SETTINGS-06 | 수면 보호 시간 설정 | 🟢 완료 | `src/routes/settings/+page.svelte` |

### NOTIFY — 푸시 알림
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| NOTIFY-01 | OneSignal SDK 초기화 | 🟢 완료 | `src/app.html`, `src/lib/onesignal.ts` |
| NOTIFY-02 | 구독 동의 UI | 🟡 대기 | `src/routes/settings/+page.svelte` |
| NOTIFY-03 | Supabase user_id와 OneSignal 연결 | 🟢 완료 | `src/lib/onesignal.ts` |

### PWA — 앱 설치
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| PWA-01 | manifest.webmanifest 설정 | 🟢 완료 | `vite.config.ts` |
| PWA-02 | 홈 화면 추가 (설치) 프롬프트 | 🟢 완료 | manifest + maskable icons |
| PWA-03 | Service Worker (오프라인 캐시) | 🟢 완료 | `vite.config.ts` (workbox) |

### DB — 데이터베이스
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| DB-01 | 전체 초기 스키마 + RLS | 🟢 완료 | `supabase/migrations/001_initial.sql` |
| DB-02 | increment_daily_stats RPC | 🟢 완료 | `supabase/migrations/001_initial.sql` |
| DB-03 | 라이브러리 스키마 (is_public, category, fork_count, forked_from) | 🟢 완료 | `supabase/migrations/002_library.sql` |

---

## v1.1.0 — 공개 라이브러리

### LIB — 라이브러리
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| LIB-01 | 공개 라이브러리 탐색 페이지 | 🟢 완료 | `src/routes/library/+page.svelte` |
| LIB-02 | 세트 공개/비공개 토글 + 카테고리 설정 | 🟢 완료 | `src/routes/sets/[id]/+page.svelte` |
| LIB-03 | 라이브러리 세트 상세 미리보기 (카드 수, 영역, 설명) | 🟢 완료 | `src/routes/library/+page.svelte` |
| LIB-04 | 세트 복제(포크) — 카드 전체 복사 + fork_count 증가 | 🟢 완료 | `src/routes/library/+page.svelte` |
| LIB-05 | 인기순/최신순 정렬 + 키워드 검색 + 카테고리 필터 | 🟢 완료 | `src/routes/library/+page.svelte` |

---

## 대기 중 / 검토 중 기능

| ID | 기능 | 상태 | 비고 |
|----|------|------|------|
| NOTIFY-02 | 설정 페이지 내 푸시 알림 구독 동의 버튼 | 🟡 대기 | OneSignal App ID 설정 후 구현 |

---

## 기능 추가 요청 처리 절차

```
1. FEATURES.md "대기 중" 섹션에 새 항목 추가 (ID: [카테고리]-[번호])
2. CLAUDE.md "금지 사항"과 충돌 확인
3. DB 변경 필요 시 supabase/migrations/ 에 새 파일 추가
4. 구현 완료 후 상태 🟢 완료로 변경 + CHANGELOG.md 항목 추가
```

---

## DB 마이그레이션 이력

| 파일 | 내용 | 적용 버전 |
|------|------|-----------|
| `001_initial.sql` | 전체 초기 스키마 (user_settings, card_sets, cards, shared_sets, review_logs, daily_stats) + RLS + increment_daily_stats RPC | v1.0.0 |
| `002_library.sql` | card_sets에 is_public, author_name, fork_count, forked_from, category 추가 + 공개 RLS 정책 + increment_fork_count RPC | v1.1.0 |
