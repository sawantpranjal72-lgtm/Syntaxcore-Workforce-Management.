-- ============================================================
-- V16: Per-assignee "started working" tracking
--
-- On a multi-assignee task there was no record of an individual
-- assignee starting their own portion of the work — only the
-- shared tasks.status field existed, and TaskSubmission rows only
-- appear once someone submits. This meant one assignee clicking
-- "Start Working" had nowhere persistent to write to, and their
-- displayed status would always fall back to a shared baseline
-- derived from tasks.status — which could already reflect a
-- completely different assignee's submission/approval outcome.
-- ============================================================

CREATE TABLE IF NOT EXISTS task_started_by (
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (task_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_task_started_by_task ON task_started_by(task_id);
CREATE INDEX IF NOT EXISTS idx_task_started_by_user ON task_started_by(user_id);
