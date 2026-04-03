# ASSETS.md — memorygod 이미지 에셋 활용 전략

> Claude Code는 이미지 관련 컴포넌트 구현 전 이 파일을 반드시 읽는다.
> 원본 파일(logo/ 폴더)은 절대 수정하지 않는다. static/ 폴더의 가공 파일만 사용한다.

---

## 원본 → 산출물 매핑

| 원본 파일 | 특징 | 용도 |
|-----------|------|------|
| `logo1.png` | 흰 배경, 라인 드로잉 | **PWA 아이콘** 소스 (가장 단순) |
| `logo2.png` | 크림 배경, 라인 드로잉 | 라이트모드 패널용 로고 |
| `colorlogo1.png` | 크림 배경, 채색 올빼미 | 스플래시 / 홈 메인 마스코트 |
| `seeyou.png` | 크림 배경, 스케치 채색 | 로그인 / 로그아웃 화면 |
| `thinking.png` | 흰 배경, 채색 + A박스 | 힌트 / 로딩 화면 |
| `emoticon.png` | 흰 배경, 5종 스케치 시트 | 감정 5종 크롭 |
| `emoticonx10.png` | 흰 배경, 13종 스케치 시트 | 감정 13종 크롭 |
| `icon.png` | ❌ **사용 안 함** | 눈에 연결 링크(분자) 디자인 포함 → 제외 |

---

## static/ 폴더 구조

```
static/
├── icons/                         ← PWA 아이콘 · 파비콘 (소스: logo1.png)
│   ├── icon-512.png
│   ├── icon-192.png
│   ├── icon-180.png               iOS apple-touch-icon
│   ├── icon-144.png
│   ├── icon-128.png
│   ├── icon-96.png
│   ├── icon-72.png
│   ├── icon-48.png
│   ├── icon-32.png
│   ├── icon-16.png
│   ├── favicon-16.png
│   └── favicon-32.png
│
├── logo/                          ← 앱 로고 · 대표 이미지
│   ├── owl-white-bg.png           흰배경 라인 드로잉 (300×540)
│   ├── owl-white-bg@2x.png        Retina (600×1080)
│   ├── owl-cream-bg.png           크림배경 라인 드로잉 (300×540)
│   ├── owl-cream-bg@2x.png        Retina (600×1080)
│   ├── owl-color.png              채색 올빼미 전신 (300×480)
│   ├── owl-color@2x.png           Retina (600×960)
│   ├── owl-face.png               채색 얼굴 클로즈업 (200×160)
│   └── owl-face@2x.png            Retina (400×320)
│
├── splash/                        ← 스플래시 · 특수 화면
│   ├── owl-seeyou.png             스케치 채색 전신 (360×480)
│   ├── owl-seeyou@2x.png          Retina (720×960)
│   ├── owl-thinking.png           채색+A박스 전신 (320×480)
│   ├── owl-thinking@2x.png        Retina (640×960)
│   └── owl-thinking-face.png      얼굴 클로즈업 (200×140)
│
└── owl-states/                    ← 상황별 이모티콘 (총 18종)
    │
    │   ── emoticon.png 크롭 5종 (240×240 / @2x 480×480) ──
    ├── thinking.png / @2x         생각중 💭
    ├── confused.png / @2x         헷갈림
    ├── surprised.png / @2x        놀람 / 알아냄
    ├── happy.png / @2x            기쁨 / 정답 ✨
    ├── sleeping.png / @2x         수면 ZZZ
    │
    │   ── emoticonx10.png 크롭 13종 (200×200) ──
    ├── e_thinking.png
    ├── e_confused.png
    ├── e_surprised.png
    ├── e_happy.png
    ├── e_panic.png                패닉 / 에러
    ├── e_angry.png                화남 / 경고
    ├── e_love.png                 좋아요 / 하트
    ├── e_sick.png                 피곤 / 아픔
    ├── e_bored.png                지루함 / 빈 상태
    ├── e_fear.png                 두려움 / 주의
    ├── e_worry.png                걱정
    ├── e_sing.png                 즐거움 / 완료
    └── e_smug.png                 자신만만 / 고숙달
```

---

## 화면별 사용 파일

### app.html — 파비콘
```html
<link rel="icon" href="%sveltekit.assets%/icons/favicon-32.png" type="image/png">
<link rel="apple-touch-icon" href="%sveltekit.assets%/icons/icon-180.png">
```

### manifest.json — PWA 아이콘
```json
{
  "icons": [
    { "src": "/memorygod/icons/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/memorygod/icons/icon-512.png",  "sizes": "512x512",  "type": "image/png" }
  ]
}
```

### +layout.svelte — 앱 로딩 스플래시
```svelte
{#if loading}
  <div class="fixed inset-0 flex flex-col items-center justify-center bg-white">
    <img
      src="/memorygod/logo/owl-color.png"
      srcset="/memorygod/logo/owl-color@2x.png 2x"
      alt="기억의 신" class="w-40" />
    <p class="mt-4 text-sm text-gray-400">기억을 불러오는 중...</p>
  </div>
{/if}
```

### auth/login — 로그인 화면
```svelte
<img
  src="/memorygod/splash/owl-seeyou.png"
  srcset="/memorygod/splash/owl-seeyou@2x.png 2x"
  alt="" aria-hidden="true" class="w-48 mx-auto" />
```

---

## 상황 → 파일 매핑표

| 상황 | 파일 | 권장 크기 |
|------|------|-----------|
| 앱 로딩 스플래시 | `logo/owl-color.png` | w-40 |
| 홈 대시보드 마스코트 | `logo/owl-face.png` | w-16 |
| 로그인 / 온보딩 | `splash/owl-seeyou.png` | w-48 |
| 로그아웃 완료 | `splash/owl-seeyou.png` | w-40 |
| 힌트 버튼 클릭 | `splash/owl-thinking.png` | w-32 |
| 로딩 인디케이터 (소형) | `splash/owl-thinking-face.png` | w-12 |
| 평가: 알았음 ✓ | `owl-states/happy.png` | w-20 |
| 평가: 헷갈림 ~ | `owl-states/confused.png` | w-20 |
| 평가: 몰랐음 ✗ | `owl-states/e_worry.png` | w-20 |
| 학습 세션 완료 | `owl-states/e_sing.png` | w-32 |
| 빈 상태 (카드 없음) | `owl-states/e_bored.png` | w-28 |
| 에러 발생 | `owl-states/e_panic.png` | w-20 |
| 스트릭 달성 / 별점 5점 | `owl-states/e_love.png` | w-20 |
| 수면 보호 시간 알림 | `owl-states/sleeping.png` | w-20 |
| 숙달도 80% 이상 달성 | `owl-states/e_smug.png` | w-20 |
| 업로드 완료 | `owl-states/e_sing.png` | w-20 |
| 에러 / 경고 | `owl-states/e_angry.png` | w-20 |

---

## OwlMascot.svelte 공통 컴포넌트 명세

Claude Code는 아래 명세대로 `src/lib/components/OwlMascot.svelte`를 구현한다.

```svelte
<script lang="ts">
  export let state: OwlState = 'happy';
  export let size: 'xs' | 'sm' | 'md' | 'lg' | 'xl' = 'md';

  type OwlState =
    | 'loading' | 'seeyou' | 'thinking'
    | 'happy' | 'confused' | 'surprised' | 'sleeping'
    | 'panic' | 'love' | 'bored' | 'sing' | 'smug'
    | 'worry' | 'angry' | 'fear';

  const BASE = '/memorygod';
  const SRC_MAP: Record<OwlState, string> = {
    loading:   `${BASE}/logo/owl-color.png`,
    seeyou:    `${BASE}/splash/owl-seeyou.png`,
    thinking:  `${BASE}/splash/owl-thinking.png`,
    happy:     `${BASE}/owl-states/happy.png`,
    confused:  `${BASE}/owl-states/confused.png`,
    surprised: `${BASE}/owl-states/surprised.png`,
    sleeping:  `${BASE}/owl-states/sleeping.png`,
    panic:     `${BASE}/owl-states/e_panic.png`,
    love:      `${BASE}/owl-states/e_love.png`,
    bored:     `${BASE}/owl-states/e_bored.png`,
    sing:      `${BASE}/owl-states/e_sing.png`,
    smug:      `${BASE}/owl-states/e_smug.png`,
    worry:     `${BASE}/owl-states/e_worry.png`,
    angry:     `${BASE}/owl-states/e_angry.png`,
    fear:      `${BASE}/owl-states/e_fear.png`,
  };

  const SIZE_MAP = {
    xs: 'w-8 h-8',
    sm: 'w-12 h-12',
    md: 'w-20 h-20',
    lg: 'w-32 h-32',
    xl: 'w-48 h-48',
  };
</script>

<img
  src={SRC_MAP[state]}
  alt=""
  aria-hidden="true"
  class="{SIZE_MAP[size]} object-contain"
/>
```

**사용 예시:**
```svelte
<OwlMascot state="happy" size="lg" />    <!-- 학습 완료 -->
<OwlMascot state="panic" size="sm" />    <!-- 에러 토스트 옆 -->
<OwlMascot state="loading" size="xl" />  <!-- 스플래시 -->
<OwlMascot state="bored" size="md" />    <!-- 빈 세트 안내 -->
```
