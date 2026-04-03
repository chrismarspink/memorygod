-- ============================================================
-- 003_set_toggle.sql — 세트 ON/OFF (다중 활성화)
-- v1.2.0 SETS-07~10
-- ============================================================

-- 본인 세트 ON/OFF 컬럼 추가
ALTER TABLE card_sets
  ADD COLUMN IF NOT EXISTS is_enabled boolean DEFAULT true;

-- 기존 세트는 기본 ON
UPDATE card_sets SET is_enabled = true WHERE is_enabled IS NULL;

-- shared_sets.is_active 의미 변경: 1개 제한 → 다중 허용
-- 컬럼은 그대로 유지, 기존 데이터 모두 활성화
UPDATE shared_sets SET is_active = true WHERE is_active IS NULL;

COMMENT ON COLUMN card_sets.is_enabled IS
  '학습 큐 포함 여부 ON/OFF (true=학습 대상, false=제외)';
COMMENT ON COLUMN shared_sets.is_active IS
  '공유받은 세트 학습 포함 여부 ON/OFF (다중 활성화 허용)';
