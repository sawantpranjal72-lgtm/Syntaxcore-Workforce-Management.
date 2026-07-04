-- ============================================================
-- V8: SyntaxCore Enhancements
-- Timezone: Asia/Kolkata (IST)
-- ============================================================

-- Set default timezone for this session
SET timezone = 'Asia/Kolkata';

-- ── Working Schedule Settings ────────────────────────────────
CREATE TABLE IF NOT EXISTS working_schedule (
    id                    BIGSERIAL PRIMARY KEY,
    working_days          VARCHAR(200) NOT NULL DEFAULT 'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY',
    work_start_time       VARCHAR(10)  NOT NULL DEFAULT '09:00',
    work_end_time         VARCHAR(10)  NOT NULL DEFAULT '18:00',
    working_hours_per_day DOUBLE PRECISION NOT NULL DEFAULT 8.0,
    grace_minutes         INTEGER NOT NULL DEFAULT 15
);

-- Insert default schedule if not present
INSERT INTO working_schedule (working_days, work_start_time, work_end_time, working_hours_per_day, grace_minutes)
SELECT 'MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY', '09:00', '18:00', 8.0, 15
WHERE NOT EXISTS (SELECT 1 FROM working_schedule);

-- ── Task Multi-Assignees ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS task_assignees (
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (task_id, user_id)
);

-- Index for fast lookup
CREATE INDEX IF NOT EXISTS idx_task_assignees_task  ON task_assignees(task_id);
CREATE INDEX IF NOT EXISTS idx_task_assignees_user  ON task_assignees(user_id);

-- ── Task Submissions (submit for review with comment/file) ────
CREATE TABLE IF NOT EXISTS task_submissions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id             UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    submitted_by_id     UUID NOT NULL REFERENCES users(id),
    description         TEXT,
    submission_file_url VARCHAR(500),
    status              VARCHAR(30) NOT NULL DEFAULT 'PENDING',   -- PENDING, APPROVED, REJECTED
    review_feedback     TEXT,
    reviewed_by_id      UUID REFERENCES users(id),
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    submitted_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_task_submissions_task   ON task_submissions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_submissions_user   ON task_submissions(submitted_by_id);

-- ── Ensure tasks table has assignee_ids JSON column ───────────
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS assignee_ids TEXT;

-- ── User Sessions: Add forceNewSession tracking ────────────────
ALTER TABLE user_sessions ADD COLUMN IF NOT EXISTS revoked_reason VARCHAR(100);

-- ── Add timezone comment to attendance ───────────────────────
COMMENT ON TABLE attendance IS 'All timestamps stored in Asia/Kolkata (IST) timezone';
COMMENT ON TABLE tasks       IS 'Deadlines stored in IST. Multi-assignee via task_assignees table.';

