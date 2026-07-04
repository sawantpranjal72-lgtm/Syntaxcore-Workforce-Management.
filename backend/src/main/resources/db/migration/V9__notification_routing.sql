-- ============================================================
-- V9: Notification routing + working improvements
-- ============================================================

-- Add action_url column if missing (for deep-link routing)
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS action_url VARCHAR(500);

-- Add entity_type and entity_id if missing
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS entity_type VARCHAR(50);
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS entity_id   UUID;

-- Populate action_url from existing data for task notifications
UPDATE notifications
SET action_url = '/tasks/' || entity_id::text
WHERE entity_type = 'TASK' AND entity_id IS NOT NULL AND action_url IS NULL;

UPDATE notifications
SET action_url = '/leaves'
WHERE type LIKE 'LEAVE%' AND action_url IS NULL;

UPDATE notifications
SET action_url = '/projects/' || entity_id::text
WHERE entity_type = 'PROJECT' AND entity_id IS NOT NULL AND action_url IS NULL;

-- Add otp_key column to otp_records to support email-as-key lookup
ALTER TABLE otp_records ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Index for email-based OTP lookup
CREATE INDEX IF NOT EXISTS idx_otp_email ON otp_records(email);

-- Task submissions: add created_at if missing
ALTER TABLE task_submissions ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE task_submissions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Leave requests: add updated_at and review_comment if missing
ALTER TABLE leaves ADD COLUMN IF NOT EXISTS updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE leaves ADD COLUMN IF NOT EXISTS review_comment VARCHAR(500);


-- Make otp_records.phone nullable (used as email key for users without phone)
ALTER TABLE otp_records ALTER COLUMN phone DROP NOT NULL;
ALTER TABLE otp_records ALTER COLUMN phone TYPE VARCHAR(255);

