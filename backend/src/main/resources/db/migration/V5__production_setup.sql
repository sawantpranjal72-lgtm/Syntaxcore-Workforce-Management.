-- V5 — Production readiness
-- Ensure indexes exist for performance
CREATE INDEX IF NOT EXISTS idx_users_email       ON users(email)         WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_users_role        ON users(role)          WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_users_dept        ON users(department_id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_tasks_assignee    ON tasks(assignee_id)   WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_tasks_project     ON tasks(project_id)    WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_tasks_status      ON tasks(status)        WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_attendance_date   ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_user   ON attendance(user_id, date);
CREATE INDEX IF NOT EXISTS idx_leaves_user       ON leave_requests(user_id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_leaves_status     ON leave_requests(status)  WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_chat_recipient    ON chat_messages(recipient_id, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(recipient_id, is_read, created_at);
