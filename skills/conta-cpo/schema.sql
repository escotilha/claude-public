-- /conta-cpo Schema (SQLite dialect)
-- DB: ~/.claude-setup/data/conta-cpo.db
-- Init: mkdir -p ~/.claude-setup/data && sqlite3 ~/.claude-setup/data/conta-cpo.db < schema.sql
-- Ported from /vibc schema.sql. Changes: SERIAL→INTEGER PRIMARY KEY AUTOINCREMENT,
-- JSONB→TEXT (JSON stored as text, queried with json_extract), TIMESTAMPTZ→TEXT (ISO-8601),
-- UUID→TEXT (random UUID generated in skill code, not DB). Seats 1..8. Types: 7 Contably types.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS conta_cpo_decisions (
  id                   TEXT PRIMARY KEY,               -- UUIDv4 generated in skill code
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  decision_type        TEXT NOT NULL DEFAULT 'general'
                       CHECK (decision_type IN (
                         'product-feature','compliance','pricing-gtm',
                         'architecture','crisis','ux-flow','general'
                       )),
  mode                 TEXT NOT NULL DEFAULT 'full' CHECK (mode IN ('full','quick')),
  status               TEXT NOT NULL DEFAULT 'deliberating'
                       CHECK (status IN ('deliberating','scored','closed')),
  framing              TEXT NOT NULL DEFAULT '{}',     -- JSON
  collision_map        TEXT DEFAULT '{}',              -- JSON
  selected_option_id   TEXT,
  dimension_weights    TEXT DEFAULT '{}',              -- JSON
  final_score          REAL,
  user_choice          TEXT,
  context_block_hash   TEXT,                           -- sha1 of the contably-os context block used
  created_at           TEXT NOT NULL DEFAULT (datetime('now')),
  decided_at           TEXT,
  metadata             TEXT DEFAULT '{}'               -- JSON
);

CREATE TABLE IF NOT EXISTS conta_cpo_board_inputs (
  id                   INTEGER PRIMARY KEY AUTOINCREMENT,
  decision_id          TEXT NOT NULL REFERENCES conta_cpo_decisions(id) ON DELETE CASCADE,
  seat_number          INTEGER NOT NULL CHECK (seat_number BETWEEN 1 AND 8),
  archetype            TEXT NOT NULL,
  position             TEXT NOT NULL,
  reasoning            TEXT NOT NULL,
  concerns             TEXT,                           -- JSON array
  conditions           TEXT,                           -- JSON array
  confidence           INTEGER CHECK (confidence BETWEEN 1 AND 10),
  dissent_strength     INTEGER CHECK (dissent_strength BETWEEN 0 AND 10),
  key_quote            TEXT,
  raw_response         TEXT DEFAULT '{}',              -- JSON (full agent response)
  created_at           TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(decision_id, seat_number)
);

CREATE TABLE IF NOT EXISTS conta_cpo_options (
  id                   TEXT PRIMARY KEY,               -- UUIDv4 generated in skill code
  decision_id          TEXT NOT NULL REFERENCES conta_cpo_decisions(id) ON DELETE CASCADE,
  option_number        INTEGER NOT NULL,
  title                TEXT NOT NULL,
  description          TEXT NOT NULL,
  core_bets            TEXT NOT NULL,                  -- JSON array
  kill_conditions      TEXT NOT NULL,                  -- JSON array
  reversibility_score  INTEGER NOT NULL CHECK (reversibility_score BETWEEN 1 AND 10),
  scores               TEXT NOT NULL DEFAULT '{}',     -- JSON object of per-dimension scores
  weighted_total       REAL,
  supporting_seats     TEXT,                           -- JSON array of seat_numbers
  opposing_seats       TEXT,                           -- JSON array of seat_numbers
  created_at           TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(decision_id, option_number)
);

CREATE TABLE IF NOT EXISTS conta_cpo_retrospectives (
  id                   INTEGER PRIMARY KEY AUTOINCREMENT,
  decision_id          TEXT NOT NULL REFERENCES conta_cpo_decisions(id) ON DELETE CASCADE,
  actual_outcome       TEXT NOT NULL,
  outcome_rating       INTEGER CHECK (outcome_rating BETWEEN 1 AND 10),
  prediction_accuracy  INTEGER CHECK (prediction_accuracy BETWEEN 1 AND 10),
  best_predictor_seat  INTEGER,
  worst_predictor_seat INTEGER,
  lessons_learned      TEXT,                           -- JSON array
  surprise_factors     TEXT,                           -- JSON array
  retrospective_at     TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(decision_id)
);

CREATE INDEX IF NOT EXISTS idx_conta_cpo_board_inputs_decision
  ON conta_cpo_board_inputs(decision_id);
CREATE INDEX IF NOT EXISTS idx_conta_cpo_options_decision
  ON conta_cpo_options(decision_id);
CREATE INDEX IF NOT EXISTS idx_conta_cpo_decisions_status
  ON conta_cpo_decisions(status);
CREATE INDEX IF NOT EXISTS idx_conta_cpo_decisions_created
  ON conta_cpo_decisions(created_at DESC);

-- Batting average view: per-seat prediction accuracy across all closed retrospectives.
DROP VIEW IF EXISTS conta_cpo_batting_average;
CREATE VIEW conta_cpo_batting_average AS
SELECT
  bi.seat_number,
  bi.archetype,
  COUNT(DISTINCT r.decision_id)                                  AS decisions_reviewed,
  AVG(r.prediction_accuracy)                                     AS avg_prediction_accuracy,
  SUM(CASE WHEN r.best_predictor_seat  = bi.seat_number THEN 1 ELSE 0 END) AS times_best_predictor,
  SUM(CASE WHEN r.worst_predictor_seat = bi.seat_number THEN 1 ELSE 0 END) AS times_worst_predictor
FROM conta_cpo_board_inputs bi
JOIN conta_cpo_retrospectives r ON r.decision_id = bi.decision_id
GROUP BY bi.seat_number, bi.archetype
ORDER BY avg_prediction_accuracy DESC;
