-- ============================================================
-- V8: Work Schedule + Task Multi-Assignee + Attendance fixes
-- ============================================================

-- Work schedule table (admin-configurable working days & hours)
CREATE TABLE IF NOT EXISTS work_schedule (
    id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                      VARCHAR(100) NOT NULL DEFAULT 'Default',
    working_days              VARCHAR(20)  NOT NULL DEFAULT '1,2,3,4,5',
    standard_hours_per_day    NUMERIC(5,2) NOT NULL DEFAULT 8.0,
    standard_hours_per_week   NUMERIC(5,2) NOT NULL DEFAULT 40.0,
    grace_period_minutes      INT          NOT NULL DEFAULT 15,
    check_in_time             VARCHAR(10)           DEFAULT '09:00',
    check_out_time            VARCHAR(10)           DEFAULT '18:00',
    half_day_threshold_hours  NUMERIC(5,2)          DEFAULT 4.0,
    is_active                 BOOLEAN      NOT NULL DEFAULT TRUE,
    is_deleted                BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at                TIMESTAMP,
    created_at                TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMP,
    created_by                VARCHAR(255),
    updated_by                VARCHAR(255)
);

-- Seed default work schedule
INSERT INTO work_schedule (name, working_days, standard_hours_per_day, standard_hours_per_week,
                           grace_period_minutes, check_in_time, check_out_time, half_day_threshold_hours, is_active)
VALUES ('Default', '1,2,3,4,5', 8.0, 40.0, 15, '09:00', '18:00', 4.0, TRUE)
ON CONFLICT DO NOTHING;

-- Ensure task_assignees join table exists
CREATE TABLE IF NOT EXISTS task_assignees (
    task_id  UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_task_assignees_task ON task_assignees(task_id);
CREATE INDEX IF NOT EXISTS idx_task_assignees_user ON task_assignees(user_id);

-- Per-user task status tracking (one task, multiple users, each with own status)
CREATE TABLE IF NOT EXISTS task_user_status (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status      VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    started_at  TIMESTAMP,
    submitted_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    CONSTRAINT uk_task_user_status UNIQUE (task_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_task_user_status_task ON task_user_status(task_id);
CREATE INDEX IF NOT EXISTS idx_task_user_status_user ON task_user_status(user_id);
