# FEATURES.md — memorygod 기능 명세 및 변경 이력

> Claude Code는 새 기능 추가 전 반드시 이 파일을 읽는다.
> 기능이 확정되면 이 파일에 추가하고, CHANGELOG.md에도 기록한다.

---

## 이 파일의 사용법

### 기능 추가 요청이 들어올 때 Claude Code가 할 일
1. `## 확정 기능 목록`에서 해당 기능이 이미 있는지 확인
2. 없으면 `## 대기 중 / 검토 중` 섹션에서 찾기
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

> 아래 기능들은 모두 CLAUDE.md의 초기 설계에서 확정된 것들이다.
> Claude Code는 이 기능들을 기본 구현 대상으로 삼는다.

### AUTH — 인증
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| AUTH-01 | 이메일/패스워드 회원가입 | 🟡 대기 | `src/routes/auth/register/+page.svelte` |
| AUTH-02 | 이메일/패스워드 로그인 | 🟡 대기 | `src/routes/auth/login/+page.svelte` |
| AUTH-03 | 로그아웃 | 🟡 대기 | `src/routes/settings/+page.svelte` |
| AUTH-04 | 세션 유지 (Supabase Auth) | 🟡 대기 | `src/lib/supabase.ts` |

### UPLOAD — 카드 업로드
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| UPLOAD-01 | 엑셀(.xlsx) 파싱 및 카드 저장 | 🟡 대기 | `src/routes/upload/+page.svelte`, `src/lib/xlsx.ts` |
| UPLOAD-02 | CSV 파싱 | 🟡 대기 | `src/lib/xlsx.ts` |
| UPLOAD-03 | 컬럼명 별칭 처리 (앞면/front/question 등) | 🟡 대기 | `src/lib/xlsx.ts` |
| UPLOAD-04 | 업로드 진행률 표시 | 🟡 대기 | `src/routes/upload/+page.svelte` |

### STUDY — 학습
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| STUDY-01 | 오늘의 카드 큐 생성 (복습 + 신규) | 🟡 대기 | `src/routes/study/+page.svelte` |
| STUDY-02 | 플래시카드 플립 애니메이션 | 🟡 대기 | `src/lib/components/FlashCard.svelte` |
| STUDY-03 | 3단계 힌트 (글자수→첫글자→앞절반) | 🟡 대기 | `src/lib/components/FlashCard.svelte` |
| STUDY-04 | 평가 버튼 3개 (알았음/헷갈림/몰랐음) | 🟡 대기 | `src/lib/components/FlashCard.svelte` |
| STUDY-05 | SM-2 알고리즘으로 다음 복습일 계산 | 🟡 대기 | `src/lib/sm2.ts` |
| STUDY-06 | 세션 완료 결과 요약 모달 | 🟡 대기 | `src/routes/study/+page.svelte` |
| STUDY-07 | 데스크탑 2열 레이아웃 | 🟡 대기 | `src/lib/components/FlashCardDesktop.svelte` |
| STUDY-08 | 오프라인 학습 지원 (Service Worker 캐시) | 🟡 대기 | `vite.config.ts` (vite-plugin-pwa) |

### SETS — 세트 관리
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| SETS-01 | 세트 목록 조회 | 🟡 대기 | `src/routes/sets/+page.svelte` |
| SETS-02 | 세트 상세 페이지 (카드 테이블뷰) | 🟡 대기 | `src/routes/sets/[id]/+page.svelte` |
| SETS-03 | 공유 코드 생성 (MG-XXXX 형식) | 🟡 대기 | `src/routes/sets/[id]/+page.svelte` |
| SETS-04 | 공유 코드로 세트 참여 | 🟡 대기 | `src/routes/sets/+page.svelte` |
| SETS-05 | 활성 세트 전환 (1개만 활성화) | 🟡 대기 | `src/routes/sets/+page.svelte` |
| SETS-06 | 영역(domain) 필터 | 🟡 대기 | `src/lib/components/DomainFilter.svelte` |

### HOME — 홈 대시보드
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| HOME-01 | 오늘의 복습 배너 (복습N + 신규N) | 🟡 대기 | `src/routes/+page.svelte` |
| HOME-02 | 세트 목록 카드 (진행률 바 + 숙달도%) | 🟡 대기 | `src/routes/+page.svelte` |
| HOME-03 | D-day 뱃지 표시 | 🟡 대기 | `src/routes/+page.svelte` |
| HOME-04 | 통계 미니 (오늘학습/숙달도/연속일) | 🟡 대기 | `src/routes/+page.svelte` |

### STATS — 통계
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| STATS-01 | 주간 학습량 바 차트 (7일) | 🟡 대기 | `src/routes/stats/+page.svelte` |
| STATS-02 | 영역별 숙달도 게이지 바 | 🟡 대기 | `src/routes/stats/+page.svelte` |
| STATS-03 | 연속 학습 스트릭 캘린더 | 🟡 대기 | `src/lib/components/StreakCalendar.svelte` |
| STATS-04 | 전체/숙달 카드 수 + 진행률 | 🟡 대기 | `src/routes/stats/+page.svelte` |

### SETTINGS — 설정
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| SETTINGS-01 | D-day 날짜 선택 | 🟡 대기 | `src/routes/settings/+page.svelte` |
| SETTINGS-02 | 하루 새 카드 슬라이더 (5~100) | 🟡 대기 | `src/routes/settings/+page.svelte` |
| SETTINGS-03 | 하루 복습 한도 슬라이더 (10~200) | 🟡 대기 | `src/routes/settings/+page.svelte` |
| SETTINGS-04 | 카드 순서 설정 (순서대로/연관도순/영역선택) | 🟡 대기 | `src/routes/settings/+page.svelte` |
| SETTINGS-05 | 알림 시간 설정 (기본 07:30, 20:00) | 🟡 대기 | `src/routes/settings/+page.svelte` |
| SETTINGS-06 | 수면 보호 시간 설정 | 🟡 대기 | `src/routes/settings/+page.svelte` |

### NOTIFY — 푸시 알림
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| NOTIFY-01 | OneSignal SDK 초기화 | 🟡 대기 | `src/app.html`, `src/lib/onesignal.ts` |
| NOTIFY-02 | 구독 동의 UI | 🟡 대기 | `src/routes/settings/+page.svelte` |
| NOTIFY-03 | Supabase user_id와 OneSignal 연결 | 🟡 대기 | `src/lib/onesignal.ts` |

### PWA — 앱 설치
| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| PWA-01 | manifest.json 설정 | 🟡 대기 | `static/manifest.json` |
| PWA-02 | 홈 화면 추가 (설치) 프롬프트 | 🟡 대기 | `src/routes/+layout.svelte` |
| PWA-03 | Service Worker (오프라인 캐시) | 🟡 대기 | `vite.config.ts` |

---

## v1.1.0 — 라이브러리 기능 (확정)

> CLAUDE.md 금지 사항의 "마켓플레이스(크리에이터 공개 판매)"와 다름.
> 이 기능은 **무료 공개 공유** 전용이며 결제·수익화 없음. 구현 진행 가능.

### ⚠️ CLAUDE.md 수정 필요 (Claude Code가 구현 전 반드시 처리)
```
CLAUDE.md "금지 사항" 섹션의 아래 항목을 수정한다:
  변경 전: "마켓플레이스 (크리에이터 공개 판매)"
  변경 후: "마켓플레이스 (크리에이터 유료 판매 / 결제 기반 공유)"
  이유: 무료 공개 라이브러리는 허용으로 범위 명확화
```

---

### LIB — 라이브러리 (세트 공개 공유)

| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| LIB-01 | 라이브러리 페이지 (공개 세트 목록) | 🟡 대기 | `src/routes/library/+page.svelte` |
| LIB-02 | 세트 검색 (제목·도메인·태그) | 🟡 대기 | `src/routes/library/+page.svelte` |
| LIB-03 | 세트 상세 페이지 (미리보기 + 평점) | 🟡 대기 | `src/routes/library/[id]/+page.svelte` |
| LIB-04 | 세트 공개 등록 버튼 (내 세트 → 라이브러리 공개) | 🟡 대기 | `src/routes/sets/[id]/+page.svelte` |
| LIB-05 | 세트 공개 취소 (비공개 전환) | 🟡 대기 | `src/routes/sets/[id]/+page.svelte` |
| LIB-06 | 별점 평가 (1~5점, 1인 1회) | 🟡 대기 | `src/routes/library/[id]/+page.svelte`, `src/lib/components/StarRating.svelte` |
| LIB-07 | 평균 별점 + 평가 수 표시 | 🟡 대기 | `src/routes/library/+page.svelte`, `src/routes/library/[id]/+page.svelte` |
| LIB-08 | 라이브러리 세트 가져오기 (내 세트로 복사) | 🟡 대기 | `src/routes/library/[id]/+page.svelte` |
| LIB-09 | 정렬 (최신순 / 별점순 / 다운로드순) | 🟡 대기 | `src/routes/library/+page.svelte` |
| LIB-10 | 도메인 필터 (라이브러리 내) | 🟡 대기 | `src/routes/library/+page.svelte` |

---

### LIB 기능 상세 명세

#### 공개 등록 흐름
```
1. 세트 소유자 → 내 세트 상세 페이지 → [라이브러리에 공개] 버튼 클릭
2. card_sets.is_public = true 로 업데이트
3. library_ratings 테이블에 집계 행 자동 생성 (평점 0, 평가수 0)
4. 라이브러리 목록에 즉시 노출
5. 공개 취소 시 is_public = false → 목록에서 숨김 (데이터 유지)
```

#### 가져오기 흐름
```
1. 타 사용자 → 라이브러리 세트 상세 → [내 세트에 추가] 버튼
2. 원본 card_sets 행 복사 → 새 card_sets 행 생성 (owner_id = 현재 유저)
3. 원본 cards 전체 복사 → 새 set_id로 저장
4. card_sets.source_set_id = 원본 세트 ID (출처 추적용)
5. 가져온 세트는 독립적으로 관리 (원본 수정해도 영향 없음)
6. card_sets.download_count + 1 증가
```

#### 별점 평가 규칙
```
- 로그인한 사용자만 평가 가능
- 자신이 만든 세트는 평가 불가
- 1인 1세트 1회 (수정은 가능, 삭제는 불가)
- 평균 별점: library_ratings 테이블에서 avg(score) 실시간 계산
- 표시: ★★★★☆ 형태 + 숫자 (예: 4.2 / 47명)
```

---

### LIB DB 스키마 추가 (마이그레이션: `002_library.sql`)

```sql
-- card_sets 테이블에 컬럼 추가
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS
  is_public       boolean DEFAULT false,     -- 라이브러리 공개 여부
  source_set_id   uuid REFERENCES card_sets, -- 가져오기 원본 세트 ID
  download_count  integer DEFAULT 0,         -- 가져가기 횟수
  author_name     text;                      -- 공개 표시용 작성자 이름

-- 별점 평가 테이블
CREATE TABLE IF NOT EXISTS library_ratings (
  id         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id     uuid REFERENCES card_sets ON DELETE CASCADE,
  user_id    uuid REFERENCES auth.users ON DELETE CASCADE,
  score      smallint NOT NULL CHECK (score BETWEEN 1 AND 5),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(set_id, user_id)   -- 1인 1세트 1회
);

-- RLS
ALTER TABLE library_ratings ENABLE ROW LEVEL SECURITY;

-- 공개 세트는 누구나 읽기 가능
CREATE POLICY "public sets readable" ON card_sets
  FOR SELECT USING (is_public = true OR owner_id = auth.uid());

-- 별점: 누구나 읽기, 본인 것만 쓰기
CREATE POLICY "ratings readable by all" ON library_ratings
  FOR SELECT USING (true);

CREATE POLICY "ratings writable by owner" ON library_ratings
  FOR ALL USING (user_id = auth.uid());

-- 자신의 세트에 평가 방지 (DB 레벨)
CREATE POLICY "cannot rate own set" ON library_ratings
  FOR INSERT WITH CHECK (
    user_id != (SELECT owner_id FROM card_sets WHERE id = set_id)
  );

-- download_count 증가용 RPC
CREATE OR REPLACE FUNCTION increment_download_count(p_set_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE card_sets SET download_count = download_count + 1
  WHERE id = p_set_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### LIB 라우트 및 컴포넌트 추가

```
신규 추가 파일:
src/routes/library/
  +page.svelte              ← 라이브러리 목록 + 검색 + 정렬 + 도메인 필터
  [id]/
    +page.svelte            ← 세트 상세 (카드 미리보기 5장 + 별점 + 가져오기)

src/lib/components/
  StarRating.svelte         ← 별점 입력 + 표시 컴포넌트 (1~5 ★)
  LibraryCard.svelte        ← 라이브러리 목록용 카드 컴포넌트

수정 파일:
src/routes/sets/[id]/+page.svelte
  → [라이브러리에 공개] / [공개 취소] 버튼 추가

src/routes/+layout.svelte
  → 네비게이션에 "라이브러리" 탭 추가 (탭 6번째)
```

---

### LIB 네비게이션 탭 변경

```
변경 전 (v1.0.0):
  홈 | 학습 | 내 세트 | 통계 | 설정

변경 후 (v1.1.0):
  홈 | 학습 | 내 세트 | 라이브러리 | 통계 | 설정

모바일: 하단 탭 6개 → 아이콘만 표시 (텍스트 숨김)
데스크탑: 좌측 사이드바에 라이브러리 항목 추가
라이브러리 탭 아이콘: 📚 또는 SVG 책 아이콘
```

---

## v1.2.0 — 세트 ON/OFF (다중 활성화) 기능 (확정)

> 기존 v1.0.0의 SETS-05 "활성 세트 전환 (1개만 활성화)" 를 **대체**한다.
> SETS-05는 ⚫ 취소 처리하고 아래 SETS-07~10으로 교체한다.

---

### ⚠️ 기존 로직 변경 주의사항 (Claude Code 필독)

```
변경 전 (SETS-05):
  - 한 번에 세트 1개만 활성화 가능
  - shared_sets.is_active = true 인 행이 1개만 존재
  - 학습 큐는 단일 활성 세트의 카드만 포함

변경 후 (SETS-07~10):
  - 여러 세트를 동시에 ON 상태로 설정 가능
  - 각 세트마다 독립적으로 ON/OFF 토글
  - 학습 큐는 ON 상태인 모든 세트의 카드를 합산해서 생성
  - 본인 세트 + 공유받은 세트 모두 ON/OFF 적용 가능

DB 변경:
  - shared_sets.is_active 컬럼 → 의미 변경 (1개 제한 → 다중 허용)
  - card_sets 테이블에 is_enabled 컬럼 추가 (본인 세트용 ON/OFF)
  - 마이그레이션: 003_set_toggle.sql
```

---

### SETS — 세트 ON/OFF 관련 기능

| ID | 기능 | 상태 | 파일 위치 |
|----|------|------|-----------|
| SETS-05 | ~~활성 세트 전환 (1개만 활성화)~~ | ⚫ 취소 | SETS-07~10으로 대체 |
| SETS-07 | 내 세트 목록에 ON/OFF 토글 스위치 | 🟡 대기 | `src/routes/sets/+page.svelte` |
| SETS-08 | 공유받은 세트 ON/OFF 토글 스위치 | 🟡 대기 | `src/routes/sets/+page.svelte` |
| SETS-09 | ON 세트만 학습 큐에 포함 (getDailyQueue 수정) | 🟡 대기 | `src/routes/study/+page.svelte` |
| SETS-10 | 홈 대시보드에 ON 세트 수 / 전체 세트 수 표시 | 🟡 대기 | `src/routes/+page.svelte` |

---

### SETS ON/OFF 상세 명세

#### UI 흐름
```
내 세트 페이지 (/sets):
  ┌─────────────────────────────────┐
  │ 정보처리기사 핵심    [●─] ON   │  ← 토글 스위치
  │ 카드 120장 · 숙달 34%           │
  ├─────────────────────────────────┤
  │ [공유] 네트워크 기초  [─○] OFF │  ← OFF 상태
  │ 카드 80장 · 숙달 12%            │
  ├─────────────────────────────────┤
  │ [공유] 보안 핵심      [●─] ON  │
  │ 카드 95장 · 숙달 67%            │
  └─────────────────────────────────┘
  현재 학습 대상: 2개 세트 · 총 215장
```

#### ON/OFF 토글 동작 규칙
```
1. 토글 클릭 → 즉시 DB 업데이트 (낙관적 업데이트 적용)
2. 최소 1개는 반드시 ON 유지 → 마지막 ON 세트를 OFF 시도하면 토스트 경고
3. OFF 세트의 카드는 학습 큐에서 완전히 제외
4. OFF 세트의 review_logs 데이터는 유지 (나중에 다시 ON 하면 이어서 학습)
5. 세트 목록 상단에 "학습 중 N개 세트 · 총 M장" 요약 표시
```

#### getDailyQueue() 수정 내용
```typescript
// 변경 전: activeSetId 단일 값 사용
.in('set_id', [activeSetId])

// 변경 후: ON 상태인 세트 ID 배열 사용
const enabledSetIds = await getEnabledSetIds(userId);  // ON인 세트 전체
.in('set_id', enabledSetIds)

// getEnabledSetIds 구현:
async function getEnabledSetIds(userId: string): Promise<string[]> {
  // 본인 세트 중 is_enabled = true
  const { data: ownSets } = await supabase
    .from('card_sets')
    .select('id')
    .eq('owner_id', userId)
    .eq('is_enabled', true);

  // 공유받은 세트 중 is_active = true
  const { data: sharedSets } = await supabase
    .from('shared_sets')
    .select('set_id')
    .eq('member_id', userId)
    .eq('is_active', true);

  return [
    ...(ownSets?.map(s => s.id) ?? []),
    ...(sharedSets?.map(s => s.set_id) ?? []),
  ];
}
```

---

### SETS ON/OFF DB 스키마 변경 (마이그레이션: `003_set_toggle.sql`)

```sql
-- 본인 세트 ON/OFF 컬럼 추가
ALTER TABLE card_sets
  ADD COLUMN IF NOT EXISTS is_enabled boolean DEFAULT true;
-- 기존 세트는 기본 ON으로 설정
UPDATE card_sets SET is_enabled = true WHERE is_enabled IS NULL;

-- shared_sets.is_active 의미 변경: 1개 제한 → 다중 허용
-- 컬럼 자체는 그대로 유지, 제약조건만 제거
-- (기존 1개 제한 로직은 클라이언트 코드에서 제거)

-- 코멘트 업데이트
COMMENT ON COLUMN card_sets.is_enabled IS
  '학습 큐 포함 여부 ON/OFF (true=학습 대상, false=제외)';
COMMENT ON COLUMN shared_sets.is_active IS
  '공유받은 세트 학습 포함 여부 ON/OFF (다중 활성화 허용)';
```

---

### 수정 대상 파일 목록

```
신규 없음.

수정 파일:
src/routes/sets/+page.svelte
  → 각 세트 카드에 ON/OFF 토글 스위치 추가
  → 상단에 "학습 중 N개 · 총 M장" 요약 추가
  → 마지막 ON 세트 OFF 방지 로직

src/routes/study/+page.svelte
  → getDailyQueue()에서 단일 activeSetId → getEnabledSetIds() 배열로 변경

src/routes/+page.svelte (홈)
  → "오늘의 복습 배너" 카드 수를 ON 세트 기준으로 계산

supabase/migrations/003_set_toggle.sql
  → 신규 생성
```

---

## 대기 중 / 검토 중 기능

> 사용자가 요청했거나 논의됐지만 아직 구현 시작 전인 기능들.
> 확정되면 위의 확정 기능 목록으로 이동시킨다.

_현재 없음 — 새 기능 요청이 오면 여기에 추가한다_

---

## 기능 추가 요청 처리 절차

사용자가 새 기능을 요청하면 아래 순서로 처리한다.

```
1. 이 파일(FEATURES.md) "대기 중" 섹션에 새 항목 추가
   - ID 형식: [카테고리]-[번호] (예: STUDY-09)
   - 상태: 🟡 대기

2. CLAUDE.md의 "금지 사항"과 충돌하는지 확인
   - 충돌하면 사용자에게 알리고 진행 중단

3. DB 스키마 변경이 필요하면:
   - supabase/migrations/ 에 새 마이그레이션 파일 추가
   - 파일명: 002_feature_name.sql, 003_feature_name.sql ...
   - FEATURES.md에 "관련 마이그레이션" 필드 추가

4. 구현 완료 후:
   - 상태를 🟢 완료로 변경
   - CHANGELOG.md에 항목 추가
   - 해당 파일 위치 업데이트
```

---

## DB 마이그레이션 이력

| 파일 | 내용 | 적용 버전 |
|------|------|-----------|
| `001_initial.sql` | 전체 초기 스키마 (user_settings, card_sets, cards, shared_sets, review_logs, daily_stats) + RLS + increment_daily_stats RPC | v1.0.0 |

> 새 마이그레이션 추가 시 이 표에도 반드시 기록한다.
