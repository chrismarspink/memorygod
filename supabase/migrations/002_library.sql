-- ============================================================
-- 002_library.sql — 공개 라이브러리 기능
-- v1.1.0 LIB-01~10
-- ============================================================

-- 1) card_sets 테이블에 라이브러리 관련 컬럼 추가
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS is_public       boolean DEFAULT false;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS author_name     text;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS source_set_id   uuid REFERENCES card_sets(id) ON DELETE SET NULL;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS download_count  integer DEFAULT 0;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS category        text;  -- 'language','history','science','it','etc'

-- 2) 별점 평가 테이블
CREATE TABLE IF NOT EXISTS library_ratings (
  id         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_id     uuid REFERENCES card_sets ON DELETE CASCADE,
  user_id    uuid REFERENCES auth.users ON DELETE CASCADE,
  score      smallint NOT NULL CHECK (score BETWEEN 1 AND 5),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(set_id, user_id)
);

-- 3) 인덱스
CREATE INDEX IF NOT EXISTS idx_card_sets_public
  ON card_sets (is_public, created_at DESC)
  WHERE is_public = true;

CREATE INDEX IF NOT EXISTS idx_card_sets_category
  ON card_sets (category)
  WHERE is_public = true;

-- 4) RLS 정책: 공개 세트는 누구나 읽기 가능
CREATE POLICY "public sets readable by all" ON card_sets
  FOR SELECT USING (is_public = true);

-- 공개 세트의 카드도 누구나 읽기 가능
CREATE POLICY "public set cards readable by all" ON cards
  FOR SELECT USING (
    set_id IN (SELECT id FROM card_sets WHERE is_public = true)
  );

-- 별점 RLS
ALTER TABLE library_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ratings readable by all" ON library_ratings
  FOR SELECT USING (true);

CREATE POLICY "ratings writable by owner" ON library_ratings
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "ratings updatable by owner" ON library_ratings
  FOR UPDATE USING (user_id = auth.uid());

-- 5) download_count 증가 함수
CREATE OR REPLACE FUNCTION increment_download_count(p_set_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE card_sets SET download_count = download_count + 1
  WHERE id = p_set_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
