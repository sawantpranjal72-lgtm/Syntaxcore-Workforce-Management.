-- ============================================================
-- SyntaxCore WMS — V3: OTP, Sessions, Leaves, Security
-- ============================================================

-- ─── OTP Records ─────────────────────────────────────────────
CREATE TABLE otp_records (
    id          BIGSERIAL PRIMARY KEY,
    phone       VARCHAR(20) NOT NULL,
    email       VARCHAR(255),
    otp_code    VARCHAR(10) NOT NULL,
    token       VARCHAR(100) UNIQUE,
    purpose     VARCHAR(50) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_used     BOOLEAN NOT NULL DEFAULT FALSE,
    attempts    INT NOT NULL DEFAULT 0,
    expires_at  TIMESTAMP NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_otp_phone  ON otp_records(phone);
CREATE INDEX idx_otp_token  ON otp_records(token);
CREATE INDEX idx_otp_expire ON otp_records(expires_at);

-- ─── User Sessions ────────────────────────────────────────────
CREATE TABLE user_sessions (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token  VARCHAR(500) NOT NULL UNIQUE,
    ip_address     VARCHAR(50),
    user_agent     TEXT,
    device_type    VARCHAR(20),
    location       VARCHAR(100),
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    last_activity  TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at     TIMESTAMP NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    revoked_at     TIMESTAMP
);

CREATE INDEX idx_session_user  ON user_sessions(user_id);
CREATE INDEX idx_session_token ON user_sessions(session_token);
CREATE INDEX idx_session_active ON user_sessions(is_active);

-- ─── Leave Requests ───────────────────────────────────────────
CREATE TABLE leave_requests (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    leave_type      VARCHAR(50) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    total_days      INT NOT NULL,
    reason          TEXT NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by_id  UUID REFERENCES users(id),
    review_comment  TEXT,
    is_half_day     BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

CREATE INDEX idx_leave_user   ON leave_requests(user_id);
CREATE INDEX idx_leave_status ON leave_requests(status);
CREATE INDEX idx_leave_dates  ON leave_requests(start_date, end_date);

-- ─── Security: Add login attempt tracking ────────────────────
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS failed_login_attempts INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS locked_until          TIMESTAMP,
    ADD COLUMN IF NOT EXISTS phone_verified        BOOLEAN NOT NULL DEFAULT FALSE;

-- ─── Seed: ensure admin phone is set ─────────────────────────
UPDATE users SET phone = '+91-9876543210', phone_verified = TRUE
  WHERE email = 'admin@syntaxcore.com';
UPDATE users SET phone = '+91-9876543211', phone_verified = TRUE
  WHERE email = 'hr@syntaxcore.com';
UPDATE users SET phone = '+91-9876543212'
  WHERE email = 'pm@syntaxcore.com';
UPDATE users SET phone = '+91-9876543213'
  WHERE email = 'lead@syntaxcore.com';
UPDATE users SET phone = '+91-9876543214'
  WHERE email = 'dev1@syntaxcore.com';
UPDATE users SET phone = '+91-9876543215'
  WHERE email = 'dev2@syntaxcore.com';
UPDATE users SET phone = '+91-9876543216'
  WHERE email = 'intern1@syntaxcore.com';
UPDATE users SET phone = '+91-9876543217'
  WHERE email = 'intern2@syntaxcore.com';

-- ─── Sample leave requests ────────────────────────────────────
