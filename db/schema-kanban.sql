-- kanban.yosegaki.db — カンバンボード
-- 生ファイル: C:\Users\dance\Documents\MEGA\kanban.yosegaki.db

CREATE TABLE IF NOT EXISTS epics (
  id        INTEGER PRIMARY KEY,
  title     TEXT NOT NULL,
  summary   TEXT,
  version   TEXT NOT NULL CHECK(version IN ('V1','V2','V3','INFRA')),
  status    TEXT NOT NULL DEFAULT 'backlog' CHECK(status IN ('backlog','active','done','cancel')),
  priority  TEXT NOT NULL DEFAULT 'P2' CHECK(priority IN ('P0','P1','P2','P3','icebox')),
  created   TEXT NOT NULL DEFAULT (datetime('now')),
  updated   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS stories (
  id        INTEGER PRIMARY KEY,
  epic_id   INTEGER REFERENCES epics(id),
  title     TEXT NOT NULL,
  summary   TEXT,
  version   TEXT NOT NULL CHECK(version IN ('V1','V2','V3','INFRA')),
  status    TEXT NOT NULL DEFAULT 'backlog' CHECK(status IN ('backlog','ready','active','review','done','cancel')),
  priority  TEXT NOT NULL DEFAULT 'P2' CHECK(priority IN ('P0','P1','P2','P3','icebox')),
  gh_repo   TEXT,
  gh_number INTEGER,
  created   TEXT NOT NULL DEFAULT (datetime('now')),
  updated   TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS tasks (
  id          INTEGER PRIMARY KEY,
  story_id    INTEGER REFERENCES stories(id),
  title       TEXT NOT NULL,
  notes       TEXT,
  status      TEXT NOT NULL DEFAULT 'backlog' CHECK(status IN ('backlog','active','review','done','cancel')),
  estimate    TEXT CHECK(estimate IN ('XS','S','M','L','XL')),
  gh_repo     TEXT,
  gh_number   INTEGER,
  assignee    TEXT,
  created     TEXT NOT NULL DEFAULT (datetime('now')),
  updated     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS log (
  id        INTEGER PRIMARY KEY,
  table_name TEXT NOT NULL,
  row_id    INTEGER NOT NULL,
  from_status TEXT,
  to_status TEXT,
  note      TEXT,
  at        TEXT NOT NULL DEFAULT (datetime('now'))
);
