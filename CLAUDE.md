# CLAUDE.md — memorygod 프로젝트 개발 지침

> 이 파일은 Claude Code가 읽고 개발을 수행하기 위한 완전한 지침서입니다.
> 모든 결정은 이 문서를 기준으로 합니다.

---

## 프로젝트 정보

| 항목 | 내용 |
|------|------|
| 프로젝트명 (영문) | memorygod |
| 프로젝트명 (한글) | 기억의 신 |
| GitHub 저장소 | https://github.com/chrismarspink/memorygod |
| 배포 URL | https://chrismarspink.github.io/memorygod |
| 버전 | v1.0.0 (MVP) |
| 개발자 | 1인 개발 |

---

## 핵심 원칙 (반드시 준수)

1. **단순함 우선**: MVP에 없는 기능은 절대 추가하지 않는다
2. **반응형 필수**: 플래시카드 페이지(학습·관리)는 모바일(375px)과 데스크탑(1280px) 모두 완전히 동작해야 한다. 나머지 페이지도 768px 이상에서 깨지지 않아야 한다.
3. **모바일 퍼스트 설계**: UI 설계는 375px 기준으로 먼저 작성하고, 768px / 1280px breakpoint에서 레이아웃을 확장한다
4. **PWA**: 앱스토어 없이 설치 가능해야 한다
5. **오프라인 기본 지원**: 오늘의 카드는 오프라인에서도 학습 가능해야 한다
6. **Supabase 직접 호출 우선**: 가능한 한 Edge Function 없이 클라이언트에서 Supabase JS SDK로 직접 쿼리한다. Edge Function은 SM-2 계산처럼 서버에서만 해야 하는 로직에만 사용한다
7. **GitHub Pages 배포**: SvelteKit을 static adapter로 설정하여 GitHub Pages에 배포한다. SSR 없음, 완전한 SPA 또는 정적 사이트로 빌드한다

---

## 기술 스택

```
Frontend:  Svelte 5 + SvelteKit 2 (static adapter)
Styling:   Tailwind CSS v4
Database:  Supabase (PostgreSQL + RLS)
Auth:      Supabase Auth (이메일/패스워드)
Storage:   Supabase Storage (이미지)
Backend:   Supabase JS SDK 직접 호출 (Edge Function 최소화)
Excel:     SheetJS (xlsx)
푸시 알림: OneSignal (외부 서비스, 무료 플랜 사용)
PWA:       vite-plugin-pwa
배포:      GitHub Pages (github.com/chrismarspink/memorygod)
CI/CD:     GitHub Actions (main 브랜치 push → 자동 배포)
```

---

## 디렉토리 구조

```
memorygod/
├── CLAUDE.md                    ← 이 파일
├── README.md
├── package.json
├── svelte.config.js             ← adapter-static 설정
├── vite.config.ts
├── tailwind.config.ts
├── .github/
│   └── workflows/
│       └── deploy.yml           ← GitHub Actions 자동 배포
├── src/
│   ├── app.html                 ← OneSignal SDK 스크립트 포함
│   ├── app.css
│   ├── lib/
│   │   ├── supabase.ts          ← Supabase 클라이언트
│   │   ├── sm2.ts               ← SM-2 알고리즘 (클라이언트 실행)
│   │   ├── onesignal.ts         ← OneSignal 초기화·구독 유틸
│   │   ├── xlsx.ts              ← 엑셀 파싱 유틸
│   │   └── components/
│   │       ├── FlashCard.svelte       ← 플래시카드 (모바일+데스크탑)
│   │       ├── FlashCardDesktop.svelte← 데스크탑 2열 레이아웃
│   │       ├── ProgressRing.svelte
│   │       ├── StreakCalendar.svelte
│   │       └── DomainFilter.svelte
│   └── routes/
│       ├── +layout.svelte       ← 공통 레이아웃 + 반응형 네비
│       ├── +page.svelte         ← 홈 대시보드
│       ├── study/
│       │   └── +page.svelte     ← 학습 플래시카드 (모바일+데스크탑)
│       ├── sets/
│       │   ├── +page.svelte     ← 내 세트 목록
│       │   └── [id]/
│       │       └── +page.svelte ← 세트 상세·관리 (모바일+데스크탑)
│       ├── upload/
│       │   └── +page.svelte     ← 엑셀 업로드
│       ├── stats/
│       │   └── +page.svelte     ← 통계
│       ├── settings/
│       │   └── +page.svelte     ← 설정
│       └── auth/
│           ├── login/
│           └── register/
├── static/
│   ├── manifest.json            ← PWA manifest
│   ├── OneSignalSDKWorker.js    ← OneSignal Service Worker (필수)
│   └── icons/
└── supabase/
    └── migrations/
        └── 001_initial.sql      ← 전체 스키마 (Edge Function 없음)
```

---

## Supabase 스키마 (완전한 DDL)

```sql
-- 확장
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 사용자 설정 (Supabase auth.users 확장)
CREATE TABLE user_settings (
  user_id          uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  daily_new_limit  integer DEFAULT 20,
  daily_rev_limit  integer DEFAULT 50,
  review_first     boolean DEFAULT true,
  study_mode       text    DEFAULT 'sequential', -- sequential | associated | domain
  selected_domains text[]  DEFAULT '{}',
  dday_date        date,                          -- 시험 D-day
  sleep_start      time    DEFAULT '23:00',       -- 수면 보호 시작
  sleep_end        time    DEFAULT '07:00',       -- 수면 보호 종료
  notify_times     text[]  DEFAULT '{"07:30","20:00"}', -- 알림 시간
  push_token       text,                          -- Web Push 구독 토큰
  updated_at       timestamptz DEFAULT now()
);

-- 카드 세트
CREATE TABLE card_sets (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id     uuid REFERENCES auth.users ON DELETE CASCADE,
  title        text NOT NULL,
  description  text,
  domains      text[] DEFAULT '{}',          -- 영역 태그 목록
  card_count   integer DEFAULT 0,
  is_shared    boolean DEFAULT false,        -- 공유 링크 활성화 여부
  share_code   text UNIQUE,                 -- 공유 코드 (6자리)
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

-- 카드
CREATE TABLE cards (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id       uuid REFERENCES card_sets ON DELETE CASCADE,
  front        text NOT NULL,               -- 앞면 (질문)
  back         text NOT NULL,               -- 뒷면 (정답)
  hint         text,                        -- 힌트 (선택)
  image_url    text,                        -- 이미지 URL (Supabase Storage)
  domain       text,                        -- 영역: 네트워크, 보안, DB 등
  tags         text[] DEFAULT '{}',         -- 태그 배열
  order_index  integer DEFAULT 0,           -- 엑셀 원본 순서
  created_at   timestamptz DEFAULT now()
);

-- 공유된 세트 (수강자 관계)
CREATE TABLE shared_sets (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id       uuid REFERENCES card_sets ON DELETE CASCADE,
  owner_id     uuid REFERENCES auth.users ON DELETE CASCADE,  -- 공유한 사람
  member_id    uuid REFERENCES auth.users ON DELETE CASCADE,  -- 공유받은 사람
  is_active    boolean DEFAULT false,       -- 활성화된 세트인지 (1인 1개만)
  joined_at    timestamptz DEFAULT now(),
  UNIQUE(set_id, member_id)
);

-- 학습 로그 (SM-2 상태 저장)
CREATE TABLE review_logs (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  card_id         uuid REFERENCES cards ON DELETE CASCADE,
  user_id         uuid REFERENCES auth.users ON DELETE CASCADE,
  result          smallint NOT NULL,         -- 5=알았음, 3=헷갈림, 1=몰랐음
  interval_days   integer DEFAULT 1,
  easiness        real    DEFAULT 2.5,
  repetition      integer DEFAULT 0,
  next_review_at  date    NOT NULL,
  reviewed_at     timestamptz DEFAULT now(),
  UNIQUE(card_id, user_id)                  -- 카드당 유저별 최신 상태 1개
);

-- 일별 학습 통계 (집계용)
CREATE TABLE daily_stats (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      uuid REFERENCES auth.users ON DELETE CASCADE,
  study_date   date NOT NULL,
  cards_studied integer DEFAULT 0,
  cards_new     integer DEFAULT 0,
  cards_review  integer DEFAULT 0,
  UNIQUE(user_id, study_date)
);

-- RLS 정책
ALTER TABLE user_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_sets      ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards          ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_sets    ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_logs    ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats    ENABLE ROW LEVEL SECURITY;

-- user_settings: 본인만
CREATE POLICY "own settings" ON user_settings
  USING (auth.uid() = user_id);

-- card_sets: 본인 세트 + 공유받은 세트
CREATE POLICY "own or shared sets" ON card_sets
  USING (
    owner_id = auth.uid() OR
    id IN (SELECT set_id FROM shared_sets WHERE member_id = auth.uid())
  );

-- cards: 세트 접근 권한 있으면 카드도 접근
CREATE POLICY "accessible cards" ON cards
  USING (
    set_id IN (
      SELECT id FROM card_sets WHERE
        owner_id = auth.uid() OR
        id IN (SELECT set_id FROM shared_sets WHERE member_id = auth.uid())
    )
  );

-- review_logs: 본인 것만
CREATE POLICY "own review logs" ON review_logs
  USING (user_id = auth.uid());

-- daily_stats: 본인 것만
CREATE POLICY "own daily stats" ON daily_stats
  USING (user_id = auth.uid());

-- shared_sets: 관련 당사자만
CREATE POLICY "shared sets access" ON shared_sets
  USING (owner_id = auth.uid() OR member_id = auth.uid());
```

---

## SM-2 알고리즘 구현 (`src/lib/sm2.ts`)

```typescript
export interface SM2State {
  interval: number;    // 다음 복습까지 일수
  easiness: number;    // 난이도 계수 (1.3 ~ 2.5)
  repetition: number;  // 연속 정답 횟수
}

export type Score = 5 | 3 | 1; // 알았음 | 헷갈림 | 몰랐음

export function calcSM2(state: SM2State, score: Score): SM2State {
  let { interval, easiness, repetition } = state;

  if (score >= 3) {
    if (repetition === 0) interval = 1;
    else if (repetition === 1) interval = 6;
    else interval = Math.round(interval * easiness);
    repetition++;
  } else {
    repetition = 0;
    interval = 1;
  }

  easiness = easiness + 0.1 - (5 - score) * (0.08 + (5 - score) * 0.02);
  easiness = Math.max(1.3, Math.round(easiness * 100) / 100);

  return { interval, easiness, repetition };
}

export function nextReviewDate(intervalDays: number): Date {
  const d = new Date();
  d.setDate(d.getDate() + intervalDays);
  return d;
}
```

---

## 백엔드 전략 — Supabase 직접 호출 우선

Edge Function을 최소화하고 Supabase JS SDK로 클라이언트에서 직접 처리한다.

### 클라이언트에서 직접 처리 (Edge Function 불필요)

```typescript
// 오늘의 카드 큐 — 클라이언트에서 직접 쿼리
async function getDailyQueue(userId: string) {
  const settings = await supabase
    .from('user_settings')
    .select('*')
    .eq('user_id', userId)
    .single();

  // 복습 카드
  const { data: reviewCards } = await supabase
    .from('review_logs')
    .select('card_id, cards(*)')
    .eq('user_id', userId)
    .lte('next_review_at', new Date().toISOString().split('T')[0])
    .limit(settings.data.daily_rev_limit);

  // 새 카드 (review_logs에 없는 카드)
  const reviewedIds = reviewCards?.map(r => r.card_id) ?? [];
  const { data: newCards } = await supabase
    .from('cards')
    .select('*')
    .in('set_id', [activeSetId])
    .not('id', 'in', `(${reviewedIds.join(',')})`)
    .order('order_index')
    .limit(settings.data.daily_new_limit);

  return { reviewCards, newCards };
}

// SM-2 계산 + 저장 — 클라이언트에서 직접
async function submitReview(cardId: string, score: 5|3|1) {
  const { data: existing } = await supabase
    .from('review_logs')
    .select('*')
    .eq('card_id', cardId)
    .eq('user_id', userId)
    .maybeSingle();

  const prev = existing ?? { interval_days: 1, easiness: 2.5, repetition: 0 };
  const next = calcSM2(prev, score);          // src/lib/sm2.ts
  const nextDate = addDays(new Date(), next.interval_days);

  await supabase.from('review_logs').upsert({
    card_id: cardId,
    user_id: userId,
    result: score,
    interval_days: next.interval,
    easiness: next.easiness,
    repetition: next.repetition,
    next_review_at: nextDate.toISOString().split('T')[0],
    reviewed_at: new Date().toISOString(),
  }, { onConflict: 'card_id,user_id' });

  // daily_stats upsert
  const today = new Date().toISOString().split('T')[0];
  await supabase.rpc('increment_daily_stats', { p_user_id: userId, p_date: today });
}
```

### Supabase RPC (SQL 함수) — daily_stats 증가용

```sql
-- supabase/migrations/001_initial.sql 에 포함
CREATE OR REPLACE FUNCTION increment_daily_stats(p_user_id uuid, p_date date)
RETURNS void AS $$
BEGIN
  INSERT INTO daily_stats (user_id, study_date, cards_studied)
  VALUES (p_user_id, p_date, 1)
  ON CONFLICT (user_id, study_date)
  DO UPDATE SET cards_studied = daily_stats.cards_studied + 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

> **Edge Function 사용 시점**: 현재 MVP에서는 Edge Function을 사용하지 않는다.
> 향후 v2에서 임베딩 생성, 정산 계산 등 서버 필수 로직이 생길 때 추가한다.

---

## OneSignal 푸시 알림

Web Push를 직접 구현하는 대신 OneSignal을 사용한다. 무료 플랜으로 충분하며,
별도 서버·VAPID 키 설정 없이 대시보드와 SDK만으로 동작한다.

### 설정 (`src/lib/onesignal.ts`)

```typescript
// OneSignal App ID는 환경변수로 관리
export const ONESIGNAL_APP_ID = import.meta.env.PUBLIC_ONESIGNAL_APP_ID;

export async function initOneSignal() {
  // OneSignal SDK는 app.html에서 CDN으로 로드
  // window.OneSignalDeferred 패턴 사용
  window.OneSignalDeferred = window.OneSignalDeferred || [];
  window.OneSignalDeferred.push(async (OneSignal) => {
    await OneSignal.init({
      appId: ONESIGNAL_APP_ID,
      notifyButton: { enable: false },  // 커스텀 UI 사용
      allowLocalhostAsSecureOrigin: true,
    });
  });
}

export async function subscribeUser() {
  window.OneSignalDeferred.push(async (OneSignal) => {
    await OneSignal.Notifications.requestPermission();
    // OneSignal이 자동으로 구독 토큰 관리
    // 외부 유저 ID 연결 (Supabase user_id)
    await OneSignal.login(supabaseUserId);
  });
}

export async function setNotificationSchedule(times: string[]) {
  // OneSignal 대시보드에서 예약 발송 설정
  // 또는 클라이언트 로컬 알림 스케줄 활용
  // Supabase user_settings에 notify_times 저장 (UI용)
}
```

### app.html에 OneSignal SDK 추가

```html
<!-- src/app.html -->
<head>
  %sveltekit.head%
  <script src="https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js" defer></script>
</head>
```

### static/OneSignalSDKWorker.js (필수 — 빌드 후 자동 복사)

```javascript
importScripts("https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js");
```

### 알림 발송 방식

```
방법 1 (권장 · 서버리스): OneSignal 대시보드에서 예약 발송
  - 매일 07:30, 20:00 자동 발송 설정
  - 수면 보호 시간은 클라이언트 수신 시 무시 처리

방법 2 (자동화): Supabase pg_cron → OneSignal REST API 호출
  - pg_cron이 07:30, 20:00에 실행
  - OneSignal REST API로 세그먼트 대상 발송
  - user_settings.notify_enabled = true인 유저만
  - 이 방법은 Supabase Pro 플랜 필요
```

### 환경 변수 업데이트

```
PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
PUBLIC_SUPABASE_ANON_KEY=eyJ...
PUBLIC_ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

## 엑셀 파싱 규칙 (`src/lib/xlsx.ts`)

```typescript
// 지원 파일: .xlsx, .csv
// 첫 번째 행 = 컬럼명 (대소문자 무관)
// 필수 컬럼: front (앞면), back (뒷면)
// 선택 컬럼: hint, domain, tags, image_url, order_index

// 컬럼명 별칭 허용:
// front = 앞면, 질문, front, question, term
// back  = 뒷면, 정답, back, answer, definition
// hint  = 힌트, hint
// domain = 영역, 카테고리, domain, category

// 이미지: image_url 컬럼에 URL 입력 OR ZIP 파일로 이미지 포함
// ZIP: 엑셀 + 이미지를 함께 압축, 이미지 파일명 = order_index.jpg
```

---

## 플래시카드 페이지 반응형 레이아웃

플래시카드 페이지(학습 `/study` + 세트 관리 `/sets/[id]`)는 모바일과 데스크탑 모두 완전히 지원한다.

### 모바일 (< 768px) — 단일 컬럼

```
┌─────────────────┐
│  세트명  7/30   │  ← 상단 고정
│ ████████░░░░░░  │  ← 진행 바
├─────────────────┤
│                 │
│   [카드 앞면]   │  ← 탭하면 플립
│                 │
├─────────────────┤
│  [알았음] [헷갈림] [몰랐음]  │
└─────────────────┘
```

### 데스크탑 (≥ 768px) — 2열 레이아웃

```
┌──────────────┬──────────────────────┐
│              │  세트명              │
│  [카드 앞면] │  진행: 7 / 30  23%  │
│              │  ──────────────────  │
│  탭하면 플립 │  오늘 복습 18장     │
│              │  새 카드 12장       │
│              │  ──────────────────  │
│              │  영역 필터:         │
│              │  [네트워크] [보안]  │
│              │  ──────────────────  │
│              │  [알았음]           │
│              │  [헷갈림]           │
│              │  [몰랐음]           │
└──────────────┴──────────────────────┘
```

### 세트 관리 페이지 데스크탑

```
┌────────────────────────────────────────┐
│ 정보처리기사 핵심  [편집] [공유코드]   │
├──────────────┬─────────────────────────┤
│ 영역 필터    │ 카드 목록 (테이블뷰)    │
│ [전체]       │ # │ 앞면 │ 뒷면 │ 영역 │
│ [네트워크]   │ 1 │ OSI  │ 7계층│ 네트 │
│ [보안]       │ 2 │ TCP  │ SYN  │ 네트 │
│ [DB]         │ 3 │ AES  │ 대칭 │ 보안 │
│              │ ...                     │
└──────────────┴─────────────────────────┘
```

### Tailwind 반응형 클래스 사용 규칙

```html
<!-- 카드 컨테이너: 모바일 단일 / 데스크탑 2열 -->
<div class="flex flex-col md:flex-row md:gap-8 md:max-w-5xl md:mx-auto">
  <div class="md:w-1/2"><!-- 카드 --></div>
  <div class="md:w-1/2"><!-- 사이드 패널 --></div>
</div>

<!-- 네비게이션: 모바일 하단 탭 / 데스크탑 좌측 사이드바 -->
<nav class="fixed bottom-0 md:fixed md:left-0 md:top-0 md:h-full md:w-16">
</nav>
```

---

## GitHub Pages 배포 설정

### svelte.config.js

```javascript
import adapter from '@sveltejs/adapter-static';

export default {
  kit: {
    adapter: adapter({
      pages: 'build',
      assets: 'build',
      fallback: '404.html',    // SPA 라우팅용
      precompress: false,
    }),
    paths: {
      base: '/memorygod',      // GitHub Pages 저장소명과 일치
    },
  },
};
```

### .github/workflows/deploy.yml

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - run: npm run build
        env:
          PUBLIC_SUPABASE_URL: ${{ secrets.PUBLIC_SUPABASE_URL }}
          PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.PUBLIC_SUPABASE_ANON_KEY }}
          PUBLIC_ONESIGNAL_APP_ID: ${{ secrets.PUBLIC_ONESIGNAL_APP_ID }}

      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
```

### GitHub 저장소 설정
1. Settings → Pages → Source: `gh-pages` 브랜치
2. Settings → Secrets → Actions에 환경 변수 3개 추가

---



### 탭 1 — 홈 (대시보드)

```
상단: 앱 로고 "기억의 신" + D-day 뱃지 + 유저 아바타
---
오늘의 복습 배너: "복습 N장 + 새 카드 N장" → [시작] 버튼
---
내 세트 목록 (카드):
  - 세트명 + 크리에이터 표시
  - 진행률 바 (완료 카드 / 전체)
  - 숙달도 % 표시
  - 공유받은 세트는 [공유] 뱃지
---
통계 미니: 오늘 학습 N장 | 숙달도 N% | 연속 N일
```

### 탭 2 — 학습 (플래시카드)

```
상단: 세트명 + 진행 바 (N/M)
---
카드 영역 (탭하면 플립):
  앞면: domain 태그 + 앞면 텍스트 + 이미지(있으면)
  뒷면: 뒷면 텍스트 + 힌트 버튼
---
힌트 버튼: 누를 때마다 단계별 공개
  1단계: 글자 수 표시
  2단계: 첫 글자 공개
  3단계: 앞 절반 공개
---
평가 버튼 3개 (뒷면 확인 후):
  [✓ 알았음 +10점] [~ 헷갈림 +4점] [✗ 몰랐음 -2점]
---
하단: 다음 복습 예정일 표시
세션 완료 시: 결과 요약 모달 (학습 수, 평균 점수, 연속 일수)
```

### 탭 3 — 마켓 → v1에서는 "내 세트"로 대체

```
세트 목록 + 업로드 버튼
각 세트: 카드 수, 도메인, 공유 상태
공유 코드 생성 / 비활성화 토글
공유받은 세트 활성화 (1개만 가능)
```

### 탭 4 — 통계

```
주간 학습량 바 차트 (7일)
영역별 숙달도 게이지 바
연속 학습 스트릭 캘린더 (7일 표시)
전체 카드 수 / 숙달 카드 수 / 진행률
```

### 탭 5 — 설정

```
학습 계획:
  - 시험 D-day 날짜 선택
  - 하루 새 카드 (슬라이더, 5~100)
  - 하루 복습 한도 (슬라이더, 10~200)
  - 카드 순서 (순서대로 | 연관도순 | 영역 선택)

알림 · 수면 보호:
  - 학습 알림 ON/OFF
  - 알림 시간 1 (기본 07:30)
  - 알림 시간 2 (기본 20:00)
  - 수면 보호 시작 시각
  - 수면 보호 종료 시각

계정:
  - 프로필 이름 편집
  - 로그아웃
```

---

## 공유 기능 상세

```
1. 세트 소유자가 [공유 코드 생성] → 6자리 코드 발급 (예: MG-A3X9)
2. 수강자가 코드 입력 → shared_sets 테이블에 추가 (is_active=false)
3. 수강자가 공유받은 세트를 [활성화] → 기존 활성 세트 비활성화 후 새 것 활성화
4. 한 번에 하나의 세트만 활성화 가능 (본인 세트 포함)
5. 활성화된 세트의 카드만 학습 큐에 들어감
6. 소유자는 언제든 공유 코드 비활성화 가능
```

---

## PWA 설정

```json
// static/manifest.json
{
  "name": "기억의 신",
  "short_name": "기억의신",
  "description": "과학적 망각곡선 암기 앱",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1B3A6B",
  "icons": [
    { "src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## 환경 변수 (.env.local)

```
PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
PUBLIC_SUPABASE_ANON_KEY=eyJ...
PUBLIC_ONESIGNAL_APP_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

> GitHub Actions에서는 repository Secrets에 동일한 이름으로 등록한다.

---

## 개발 순서 (Claude Code 실행 순서)

```
Step 1: 프로젝트 초기화
  - SvelteKit + adapter-static + Tailwind + vite-plugin-pwa 설정
  - base path '/memorygod' 설정
  - Supabase 클라이언트 연결
  - 인증 (로그인/회원가입 페이지)

Step 2: DB 스키마
  - supabase/migrations/001_initial.sql 실행
  - increment_daily_stats RPC 함수 포함
  - Supabase 대시보드에서 RLS 확인

Step 3: 핵심 학습 루프
  - 엑셀 업로드 → cards 파싱 → DB 저장
  - getDailyQueue() 클라이언트 함수
  - FlashCard 컴포넌트 (플립 애니메이션, 모바일+데스크탑)
  - submitReview() 클라이언트 함수 (SM-2 + upsert)

Step 4: 홈 대시보드
  - 오늘의 복습 배너
  - 세트 목록 + 진행률

Step 5: 통계 + 설정
  - 주간 바 차트
  - 설정 슬라이더

Step 6: 공유 기능
  - 공유 코드 생성/입력
  - 활성 세트 전환

Step 7: OneSignal 푸시 알림
  - OneSignal SDK 초기화 (app.html)
  - static/OneSignalSDKWorker.js 추가
  - 구독 동의 UI
  - 알림 예약 설정

Step 8: GitHub Pages 배포
  - .github/workflows/deploy.yml 작성
  - GitHub Secrets 환경 변수 등록
  - main 브랜치 push → 자동 배포 확인
  - https://chrismarspink.github.io/memorygod 접속 확인
```

---

## 금지 사항 (MVP에서 절대 만들지 않을 것)

- 결제 / 구독 시스템
- 마켓플레이스 (크리에이터 공개 판매)
- AI 기능 (자동 카드 생성, 임베딩)
- pgvector 연관도 (태그 기반으로 대체)
- 관리자 대시보드 (수강자 일괄 관리)
- 소셜 로그인 (이메일 인증만)
- 다국어 지원
- 게이미피케이션 (점수 리더보드)
- Supabase Edge Function (현 MVP 범위에서 불필요 — 클라이언트 직접 호출로 대체)
- SSR / 서버사이드 렌더링 (GitHub Pages는 정적 빌드만 지원)
