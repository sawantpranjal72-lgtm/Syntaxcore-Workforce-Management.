-- ============================================================
-- V17: Email action tokens for leave approval/rejection
--
-- Adds a single-use, time-limited token to leave_requests so
-- that HR managers can approve or reject a leave request
-- directly from the notification email without needing to log
-- in to the web app first. Each token is generated when the
-- leave-raised email is sent, is valid for 7 days, and is
-- cleared immediately after first use.
-- ============================================================

ALTER TABLE leave_requests
    ADD COLUMN IF NOT EXISTS email_action_token      VARCHAR(128),
    ADD COLUMN IF NOT EXISTS email_action_expires_at TIMESTAMP;

CREATE UNIQUE INDEX IF NOT EXISTS idx_leave_email_token ON leave_requests(email_action_token)
    WHERE email_action_token IS NOT NULL;
