-- ============================================================
-- SyntaxCore Workforce Management System
-- Database Migration V1 - Initial Schema
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── DEPARTMENTS ────────────────────────────────────────────
CREATE TABLE departments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    code            VARCHAR(20)  UNIQUE,
    description     TEXT,
    manager_id      UUID,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

-- ─── USERS ──────────────────────────────────────────────────
CREATE TABLE users (
    id                              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name                      VARCHAR(100) NOT NULL,
    last_name                       VARCHAR(100) NOT NULL,
    email                           VARCHAR(255) NOT NULL UNIQUE,
    password                        VARCHAR(255) NOT NULL,
    employee_id                     VARCHAR(20)  UNIQUE,
    phone                           VARCHAR(20),
    avatar_url                      VARCHAR(500),
    role                            VARCHAR(50)  NOT NULL,
    department_id                   UUID REFERENCES departments(id),
    job_title                       VARCHAR(100),
    date_of_joining                 DATE,
    date_of_birth                   DATE,
    address                         TEXT,
    skills                          TEXT,
    bio                             TEXT,
    github_url                      VARCHAR(500),
    linkedin_url                    VARCHAR(500),
    is_active                       BOOLEAN NOT NULL DEFAULT TRUE,
    is_email_verified               BOOLEAN NOT NULL DEFAULT FALSE,
    email_verification_token        VARCHAR(255),
    password_reset_token            VARCHAR(255),
    password_reset_token_expiry     TIMESTAMP,
    last_login_at                   TIMESTAMP,
    is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at                      TIMESTAMP,
    created_at                      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMP,
    created_by                      VARCHAR(255),
    updated_by                      VARCHAR(255)
);

ALTER TABLE departments ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES users(id);

CREATE INDEX idx_users_email        ON users(email);
CREATE INDEX idx_users_employee_id  ON users(employee_id);
CREATE INDEX idx_users_role         ON users(role);
CREATE INDEX idx_users_department   ON users(department_id);

-- ─── REFRESH TOKENS ─────────────────────────────────────────
CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    token       VARCHAR(500) NOT NULL UNIQUE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expiry_date TIMESTAMP NOT NULL,
    is_revoked  BOOLEAN NOT NULL DEFAULT FALSE
);

-- ─── PROJECTS ───────────────────────────────────────────────
CREATE TABLE projects (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(200) NOT NULL,
    code            VARCHAR(20)  UNIQUE,
    description     TEXT,
    status          VARCHAR(50)  NOT NULL DEFAULT 'PLANNING',
    priority        VARCHAR(50)  NOT NULL DEFAULT 'MEDIUM',
    manager_id      UUID NOT NULL REFERENCES users(id),
    start_date      DATE,
    end_date        DATE,
    budget          NUMERIC(15,2),
    tech_stack      TEXT,
    repository_url  VARCHAR(500),
    avatar_color    VARCHAR(10),
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

CREATE INDEX idx_projects_status  ON projects(status);
CREATE INDEX idx_projects_manager ON projects(manager_id);

-- ─── PROJECT MEMBERS ────────────────────────────────────────
CREATE TABLE project_members (
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id    UUID NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
    PRIMARY KEY (project_id, user_id)
);

-- ─── SPRINTS ────────────────────────────────────────────────
CREATE TABLE sprints (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(200) NOT NULL,
    goal        TEXT,
    project_id  UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    start_date  DATE,
    end_date    DATE,
    is_active   BOOLEAN NOT NULL DEFAULT FALSE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    velocity    INT,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255)
);

-- ─── MILESTONES ─────────────────────────────────────────────
CREATE TABLE milestones (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                    VARCHAR(200) NOT NULL,
    description             TEXT,
    project_id              UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    due_date                DATE,
    is_completed            BOOLEAN NOT NULL DEFAULT FALSE,
    completion_percentage   INT DEFAULT 0,
    is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at              TIMESTAMP,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP,
    created_by              VARCHAR(255),
    updated_by              VARCHAR(255)
);

-- ─── TASKS ──────────────────────────────────────────────────
CREATE TABLE tasks (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title               VARCHAR(300) NOT NULL,
    description         TEXT,
    status              VARCHAR(50)  NOT NULL DEFAULT 'PENDING',
    priority            VARCHAR(50)  NOT NULL DEFAULT 'MEDIUM',
    project_id          UUID REFERENCES projects(id),
    sprint_id           UUID REFERENCES sprints(id),
    milestone_id        UUID REFERENCES milestones(id),
    assignee_id         UUID REFERENCES users(id),
    reporter_id         UUID REFERENCES users(id),
    parent_task_id      UUID REFERENCES tasks(id),
    deadline            TIMESTAMP,
    estimated_hours     NUMERIC(6,2),
    actual_hours        NUMERIC(6,2),
    story_points        INT,
    labels              TEXT,
    tags                TEXT,
    checklist           TEXT,
    is_recurring        BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_pattern  VARCHAR(100),
    board_column        VARCHAR(50) DEFAULT 'PENDING',
    board_order         INT DEFAULT 0,
    completed_at        TIMESTAMP,
    is_deleted          BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at          TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP,
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

CREATE INDEX idx_tasks_status    ON tasks(status);
CREATE INDEX idx_tasks_project   ON tasks(project_id);
CREATE INDEX idx_tasks_assignee  ON tasks(assignee_id);
CREATE INDEX idx_tasks_deadline  ON tasks(deadline);
CREATE INDEX idx_tasks_sprint    ON tasks(sprint_id);

-- ─── TASK ASSIGNEES (multi-assign) ──────────────────────────
CREATE TABLE task_assignees (
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, user_id)
);

-- ─── TASK COMMENTS ──────────────────────────────────────────
CREATE TABLE task_comments (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id           UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    author_id         UUID NOT NULL REFERENCES users(id),
    content           TEXT NOT NULL,
    is_edited         BOOLEAN NOT NULL DEFAULT FALSE,
    parent_comment_id UUID REFERENCES task_comments(id),
    is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at        TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP,
    created_by        VARCHAR(255),
    updated_by        VARCHAR(255)
);

-- ─── TASK ATTACHMENTS ───────────────────────────────────────
CREATE TABLE task_attachments (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id          UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    uploaded_by_id   UUID NOT NULL REFERENCES users(id),
    file_name        VARCHAR(255) NOT NULL,
    file_url         VARCHAR(500) NOT NULL,
    file_type        VARCHAR(100),
    file_size        BIGINT,
    is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at       TIMESTAMP,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP,
    created_by       VARCHAR(255),
    updated_by       VARCHAR(255)
);

-- ─── TASK SUBMISSIONS ───────────────────────────────────────
CREATE TABLE task_submissions (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id             UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    submitted_by_id     UUID NOT NULL REFERENCES users(id),
    description         TEXT,
    github_link         VARCHAR(500),
    live_demo_link      VARCHAR(500),
    submission_file_url VARCHAR(500),
    status              VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    reviewed_by_id      UUID REFERENCES users(id),
    review_feedback     TEXT,
    reviewed_at         TIMESTAMP,
    submission_count    INT NOT NULL DEFAULT 1,
    is_deleted          BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at          TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP,
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255)
);

-- ─── NOTIFICATIONS ──────────────────────────────────────────
CREATE TABLE notifications (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_id    UUID REFERENCES users(id),
    type         VARCHAR(100) NOT NULL,
    title        VARCHAR(255) NOT NULL,
    message      TEXT NOT NULL,
    entity_type  VARCHAR(100),
    entity_id    UUID,
    action_url   VARCHAR(500),
    is_read      BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP,
    created_by   VARCHAR(255),
    updated_by   VARCHAR(255)
);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX idx_notifications_read      ON notifications(is_read);

-- ─── ATTENDANCE ─────────────────────────────────────────────
CREATE TABLE attendance (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date        DATE NOT NULL,
    check_in    TIMESTAMP,
    check_out   TIMESTAMP,
    total_hours NUMERIC(5,2),
    status      VARCHAR(50) NOT NULL DEFAULT 'PRESENT',
    notes       TEXT,
    location    VARCHAR(255),
    ip_address  VARCHAR(50),
    is_remote   BOOLEAN NOT NULL DEFAULT FALSE,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255),
    UNIQUE (user_id, date)
);

CREATE INDEX idx_attendance_user ON attendance(user_id);
CREATE INDEX idx_attendance_date ON attendance(date);

-- ─── WORK LOGS ──────────────────────────────────────────────
CREATE TABLE work_logs (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id      UUID REFERENCES tasks(id),
    date         DATE NOT NULL,
    hours_worked NUMERIC(5,2) NOT NULL,
    description  TEXT,
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP,
    created_by   VARCHAR(255),
    updated_by   VARCHAR(255)
);

-- ─── CHAT MESSAGES ──────────────────────────────────────────
CREATE TABLE chat_messages (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id    UUID NOT NULL REFERENCES users(id),
    recipient_id UUID REFERENCES users(id),
    channel_id   UUID,
    channel_type VARCHAR(50),
    message      TEXT NOT NULL,
    message_type VARCHAR(50) NOT NULL DEFAULT 'TEXT',
    file_url     VARCHAR(500),
    file_name    VARCHAR(255),
    reactions    TEXT,
    is_edited    BOOLEAN NOT NULL DEFAULT FALSE,
    is_read      BOOLEAN NOT NULL DEFAULT FALSE,
    reply_to_id  UUID REFERENCES chat_messages(id),
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP,
    created_by   VARCHAR(255),
    updated_by   VARCHAR(255)
);

CREATE INDEX idx_chat_sender    ON chat_messages(sender_id);
CREATE INDEX idx_chat_channel   ON chat_messages(channel_id);
CREATE INDEX idx_chat_recipient ON chat_messages(recipient_id);

-- ─── ACTIVITY LOGS ──────────────────────────────────────────
CREATE TABLE activity_logs (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES users(id),
    task_id     UUID REFERENCES tasks(id),
    action      VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id   UUID,
    old_value   TEXT,
    new_value   TEXT,
    description TEXT,
    ip_address  VARCHAR(50),
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255)
);

CREATE INDEX idx_activity_user   ON activity_logs(user_id);
CREATE INDEX idx_activity_entity ON activity_logs(entity_type, entity_id);
