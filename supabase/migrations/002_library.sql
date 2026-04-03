-- ============================================================
-- 002_library.sql — 공개 라이브러리 기능
-- v1.1.0 LIB 기능용 스키마 변경
-- ============================================================

-- 1) card_sets 테이블에 공개 라이브러리 관련 컬럼 추가
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS is_public    boolean DEFAULT false;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS author_name  text;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS fork_count   integer DEFAULT 0;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS forked_from  uuid REFERENCES card_sets(id) ON DELETE SET NULL;
ALTER TABLE card_sets ADD COLUMN IF NOT EXISTS category     text;  -- 'language','history','science','it','etc'

-- 2) 인덱스: 공개 세트 목록 조회 최적화
CREATE INDEX IF NOT EXISTS idx_card_sets_public
  ON card_sets (is_public, created_at DESC)
  WHERE is_public = true;

CREATE INDEX IF NOT EXISTS idx_card_sets_category
  ON card_sets (category)
  WHERE is_public = true;

-- 3) RLS 정책 추가: 공개 세트는 누구나 읽기 가능
CREATE POLICY "public sets readable by all" ON card_sets
  FOR SELECT USING (is_public = true);

-- 4) 공개 세트의 카드도 누구나 읽기 가능
CREATE POLICY "public set cards readable by all" ON cards
  FOR SELECT USING (
    set_id IN (SELECT id FROM card_sets WHERE is_public = true)
  );

-- 5) fork_count 증가 함수
CREATE OR REPLACE FUNCTION increment_fork_count(p_set_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE card_sets
  SET fork_count = fork_count + 1
  WHERE id = p_set_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
