-- issues.yosegaki.db — V1/V2/V3 GitHub Issues 統合管理
-- 生ファイル: C:\Users\dance\Documents\MEGA\issues.yosegaki.db

CREATE TABLE IF NOT EXISTS repos (
  id          INTEGER PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  full_name   TEXT NOT NULL UNIQUE,
  version     TEXT NOT NULL,
  focus       TEXT NOT NULL,
  url         TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS issues (
  id           INTEGER PRIMARY KEY,
  gh_number    INTEGER,
  repo_id      INTEGER NOT NULL REFERENCES repos(id),
  title        TEXT NOT NULL,
  body         TEXT,
  state        TEXT NOT NULL DEFAULT 'open',
  priority     TEXT DEFAULT 'P2',
  labels       TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT,
  closed_at    TEXT
);

CREATE TABLE IF NOT EXISTS ontology_entities (
  id          INTEGER PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  description TEXT,
  attributes  TEXT
);
