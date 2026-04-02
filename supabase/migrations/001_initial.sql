-- 확장
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 사용자 설정 (Supabase auth.users 확장)
CREATE TABLE user_settings (
  user_id          uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  daily_new_limit  integer DEFAULT 20,
  daily_rev_limit  integer DEFAULT 50,
  review_first     boolean DEFAULT true,
  study_mode       text    DEFAULT 'sequential',
  selected_domains text[]  DEFAULT '{}',
  dday_date        date,
  sleep_start      time    DEFAULT '23:00',
  sleep_end        time    DEFAULT '07:00',
  notify_times     text[]  DEFAULT '{"07:30","20:00"}',
  push_token       text,
  updated_at       timestamptz DEFAULT now()
);

-- 카드 세트
CREATE TABLE card_sets (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id     uuid REFERENCES auth.users ON DELETE CASCADE,
  title        text NOT NULL,
  description  text,
  domains      text[] DEFAULT '{}',
  card_count   integer DEFAULT 0,
  is_shared    boolean DEFAULT false,
  share_code   text UNIQUE,
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);

-- 카드
CREATE TABLE cards (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id       uuid REFERENCES card_sets ON DELETE CASCADE,
  front        text NOT NULL,
  back         text NOT NULL,
  hint         text,
  image_url    text,
  domain       text,
  tags         text[] DEFAULT '{}',
  order_index  integer DEFAULT 0,
  created_at   timestamptz DEFAULT now()
);

-- 공유된 세트
CREATE TABLE shared_sets (
  id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id       uuid REFERENCES card_sets ON DELETE CASCADE,
  owner_id     uuid REFERENCES auth.users ON DELETE CASCADE,
  member_id    uuid REFERENCES auth.users ON DELETE CASCADE,
  is_active    boolean DEFAULT false,
  joined_at    timestamptz DEFAULT now(),
  UNIQUE(set_id, member_id)
);

-- 학습 로그 (SM-2 상태 저장)
CREATE TABLE review_logs (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  card_id         uuid REFERENCES cards ON DELETE CASCADE,
  user_id         uuid REFERENCES auth.users ON DELETE CASCADE,
  result          smallint NOT NULL,
  interval_days   integer DEFAULT 1,
  easiness        real    DEFAULT 2.5,
  repetition      integer DEFAULT 0,
  next_review_at  date    NOT NULL,
  reviewed_at     timestamptz DEFAULT now(),
  UNIQUE(card_id, user_id)
);

-- 일별 학습 통계
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
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- card_sets: 본인 세트 + 공유받은 세트
CREATE POLICY "own or shared sets read" ON card_sets
  FOR SELECT USING (
    owner_id = auth.uid() OR
    id IN (SELECT set_id FROM shared_sets WHERE member_id = auth.uid())
  );

CREATE POLICY "own sets write" ON card_sets
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "own sets update" ON card_sets
  FOR UPDATE USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "own sets delete" ON card_sets
  FOR DELETE USING (owner_id = auth.uid());

-- cards: 세트 접근 권한 있으면 카드도 접근
CREATE POLICY "accessible cards read" ON cards
  FOR SELECT USING (
    set_id IN (
      SELECT id FROM card_sets WHERE
        owner_id = auth.uid() OR
        id IN (SELECT set_id FROM shared_sets WHERE member_id = auth.uid())
    )
  );

CREATE POLICY "own cards write" ON cards
  FOR INSERT WITH CHECK (
    set_id IN (SELECT id FROM card_sets WHERE owner_id = auth.uid())
  );

CREATE POLICY "own cards update" ON cards
  FOR UPDATE USING (
    set_id IN (SELECT id FROM card_sets WHERE owner_id = auth.uid())
  );

CREATE POLICY "own cards delete" ON cards
  FOR DELETE USING (
    set_id IN (SELECT id FROM card_sets WHERE owner_id = auth.uid())
  );

-- review_logs: 본인 것만
CREATE POLICY "own review logs" ON review_logs
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- daily_stats: 본인 것만
CREATE POLICY "own daily stats" ON daily_stats
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- shared_sets: 관련 당사자만
CREATE POLICY "shared sets read" ON shared_sets
  FOR SELECT USING (owner_id = auth.uid() OR member_id = auth.uid());

CREATE POLICY "shared sets insert" ON shared_sets
  FOR INSERT WITH CHECK (member_id = auth.uid());

CREATE POLICY "shared sets update" ON shared_sets
  FOR UPDATE USING (member_id = auth.uid());

CREATE POLICY "shared sets delete" ON shared_sets
  FOR DELETE USING (owner_id = auth.uid() OR member_id = auth.uid());

-- RPC: daily_stats 증가
CREATE OR REPLACE FUNCTION increment_daily_stats(
  p_user_id uuid,
  p_date date,
  p_is_new boolean DEFAULT false
)
RETURNS void AS $$
BEGIN
  INSERT INTO daily_stats (user_id, study_date, cards_studied, cards_new, cards_review)
  VALUES (
    p_user_id, p_date, 1,
    CASE WHEN p_is_new THEN 1 ELSE 0 END,
    CASE WHEN p_is_new THEN 0 ELSE 1 END
  )
  ON CONFLICT (user_id, study_date)
  DO UPDATE SET
    cards_studied = daily_stats.cards_studied + 1,
    cards_new = daily_stats.cards_new + CASE WHEN p_is_new THEN 1 ELSE 0 END,
    cards_review = daily_stats.cards_review + CASE WHEN p_is_new THEN 0 ELSE 1 END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
