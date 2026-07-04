-- ============================================================
-- V12: Exam Portal, Leave Email Notifications, Daily Attendance,
--      STUDENT role support
-- ============================================================

-- ── 1. EXAMS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exams (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title            VARCHAR(300) NOT NULL,
    description      TEXT,
    subject          VARCHAR(100),
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    total_marks      DOUBLE PRECISION NOT NULL DEFAULT 100,
    passing_marks    DOUBLE PRECISION NOT NULL DEFAULT 50,
    status           VARCHAR(30) NOT NULL DEFAULT 'DRAFT',   -- DRAFT, PUBLISHED, ACTIVE, COMPLETED
    start_time       TIMESTAMP,
    end_time         TIMESTAMP,
    target_roles     VARCHAR(300),                            -- comma-separated, e.g. 'EMPLOYEE,INTERN,STUDENT'
    questions_json   TEXT,                                     -- JSON array of question objects
    settings_json    TEXT,                                     -- JSON object: { security: {...}, options: {...} }
    created_by_id    UUID REFERENCES users(id),

    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP,
    created_by       VARCHAR(255),
    updated_by       VARCHAR(255),
    is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at       TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_exams_status ON exams(status);
CREATE INDEX IF NOT EXISTS idx_exams_deleted ON exams(is_deleted);

-- ── 2. EXAM ATTEMPTS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exam_attempts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id             UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    answers_json        TEXT,                                  -- JSON array of submitted answers
    score               DOUBLE PRECISION,
    max_score           DOUBLE PRECISION,
    passed              BOOLEAN NOT NULL DEFAULT FALSE,
    answered_count      INTEGER NOT NULL DEFAULT 0,
    total_questions     INTEGER NOT NULL DEFAULT 0,
    violation_count     INTEGER NOT NULL DEFAULT 0,
    time_taken_seconds  INTEGER,
    status              VARCHAR(30) NOT NULL DEFAULT 'IN_PROGRESS', -- IN_PROGRESS, SUBMITTED, GRADED
    submitted_at        TIMESTAMP,

    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP,
    created_by          VARCHAR(255),
    updated_by          VARCHAR(255),
    is_deleted          BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at          TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_attempt_exam ON exam_attempts(exam_id);
CREATE INDEX IF NOT EXISTS idx_attempt_user ON exam_attempts(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS uk_attempt_exam_user ON exam_attempts(exam_id, user_id);

-- ── 3. EXAM VIOLATIONS (anti-cheat log) ──────────────────────
CREATE TABLE IF NOT EXISTS exam_violations (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id          UUID NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason           VARCHAR(300) NOT NULL,
    violation_count  INTEGER NOT NULL DEFAULT 1,

    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP,
    created_by       VARCHAR(255),
    updated_by       VARCHAR(255),
    is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at       TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_violation_exam ON exam_violations(exam_id);
CREATE INDEX IF NOT EXISTS idx_violation_user ON exam_violations(user_id);

-- ── 4. LEAVE EMAIL NOTIFICATION CONFIG ────────────────────────
CREATE TABLE IF NOT EXISTS leave_email_configs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL,
    display_name  VARCHAR(150),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    leave_types   VARCHAR(500),                -- comma-separated leave types; NULL = all types
    added_by_id   UUID REFERENCES users(id),

    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP,
    created_by    VARCHAR(255),
    updated_by    VARCHAR(255),
    is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at    TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_leave_email_active ON leave_email_configs(is_active, is_deleted);
CREATE UNIQUE INDEX IF NOT EXISTS uk_leave_email_address ON leave_email_configs(email) WHERE is_deleted = FALSE;

-- ── 5. ROLE MENU ACCESS — new menu keys ──────────────────────
-- Exam Portal: visible to everyone except STUDENT-restricted exclusions handled in code
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',     'exams', true),
  (gen_random_uuid(), 'ADMINISTRATOR',   'exams', true),
  (gen_random_uuid(), 'PROJECT_MANAGER', 'exams', true),
  (gen_random_uuid(), 'HR_MANAGER',      'exams', true),
  (gen_random_uuid(), 'EMPLOYEE',        'exams', true),
  (gen_random_uuid(), 'INTERN',          'exams', true),
  (gen_random_uuid(), 'STUDENT',         'exams', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- Daily attendance report: managers only
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',     'attendance', true),
  (gen_random_uuid(), 'ADMINISTRATOR',   'attendance', true),
  (gen_random_uuid(), 'PROJECT_MANAGER', 'attendance', true),
  (gen_random_uuid(), 'HR_MANAGER',      'attendance', true),
  (gen_random_uuid(), 'EMPLOYEE',        'attendance', true),
  (gen_random_uuid(), 'INTERN',          'attendance', true),
  (gen_random_uuid(), 'STUDENT',         'attendance', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- Leave email notification config: admin/HR only
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',     'leave-email-config', true),
  (gen_random_uuid(), 'ADMINISTRATOR',   'leave-email-config', true),
  (gen_random_uuid(), 'HR_MANAGER',      'leave-email-config', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- Dashboard / notifications for STUDENT role
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'STUDENT', 'dashboard', true),
  (gen_random_uuid(), 'STUDENT', 'notifications', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- ── 6. Seed: a sample published exam for demo purposes ───────
INSERT INTO exams (id, title, description, subject, duration_minutes, total_marks, passing_marks, status, target_roles, questions_json, settings_json)
SELECT
  gen_random_uuid(),
  'JavaScript Fundamentals Assessment',
  'Test your knowledge of core JavaScript concepts: variables, operators, closures, and basic coding.',
  'JavaScript',
  45,
  20,
  10,
  'ACTIVE',
  'EMPLOYEE,INTERN,STUDENT',
  '[
    {"id":"q1","type":"MCQ","text":"Which keyword declares a variable that cannot be reassigned?","marks":2,"order":1,"options":[{"id":"a","text":"var","isCorrect":false},{"id":"b","text":"let","isCorrect":false},{"id":"c","text":"const","isCorrect":true},{"id":"d","text":"define","isCorrect":false}]},
     {"id":"q2","type":"MCQ","text":"What does the === operator check in JavaScript?","marks":2,"order":2,"options":[{"id":"a","text":"Value only","isCorrect":false},{"id":"b","text":"Type only","isCorrect":false},{"id":"c","text":"Both value and type","isCorrect":true},{"id":"d","text":"Neither","isCorrect":false}]},
     {"id":"q3","type":"SHORT","text":"Explain the difference between null and undefined in JavaScript.","marks":4,"order":3,"options":[],"expectedAnswer":"null is an explicitly assigned empty value, while undefined means a variable has been declared but not assigned a value."},
     {"id":"q4","type":"CODING","text":"Write a function that takes an array of numbers and returns only the even numbers.","marks":6,"order":4,"options":[],"codeTemplate":"function getEvens(arr) {\n  // your code here\n}","testCases":"[{\"input\":\"[1,2,3,4,5,6]\",\"expected\":\"[2,4,6]\"}]","expectedAnswer":"function getEvens(arr) {\n  return arr.filter(n => n % 2 === 0);\n}"},
     {"id":"q5","type":"LONG","text":"Explain the concept of closures in JavaScript with an example.","marks":6,"order":5,"options":[],"expectedAnswer":"A closure is a function that retains access to variables from its enclosing scope even after that scope has finished executing."}
  ]',
  '{"security":{"fullscreen":true,"tabSwitch":true,"copyPaste":true,"rightClick":true,"devTools":true,"faceDetection":false},"options":{"shuffleQuestions":false,"shuffleOptions":true,"showResult":true,"allowReview":false,"negativeMarking":false,"autoSubmit":true}}'
WHERE NOT EXISTS (SELECT 1 FROM exams WHERE title = 'JavaScript Fundamentals Assessment');

