-- ============================================================
-- V13: Exam role permissions (Super Admin delegated control)
--      + sync role_menu_access defaults that were stale
--        (missing task-approvals, working-schedule, exams,
--         leave-email-config, and the STUDENT role entirely)
-- ============================================================

-- ── 1. EXAM ROLE PERMISSIONS ──────────────────────────────────
-- Lets Super Admin decide, per role, who may create/edit/delete/
-- publish exams (can_manage) versus who may only attempt them
-- (can_take). SUPER_ADMIN is always treated as can_manage=true
-- in application code regardless of what is stored here.
CREATE TABLE IF NOT EXISTS exam_role_permissions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role         VARCHAR(50) NOT NULL,
    can_manage   BOOLEAN NOT NULL DEFAULT FALSE,
    can_take     BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP,
    created_by   VARCHAR(255),
    updated_by   VARCHAR(255),
    CONSTRAINT uk_exam_role_permissions_role UNIQUE (role)
);
CREATE INDEX IF NOT EXISTS idx_exam_role_permissions_role ON exam_role_permissions(role);

-- Seed sensible defaults matching application-level defaults
INSERT INTO exam_role_permissions (role, can_manage, can_take) VALUES
  ('SUPER_ADMIN',     true,  true),
  ('ADMINISTRATOR',   true,  true),
  ('PROJECT_MANAGER', true,  true),
  ('HR_MANAGER',      true,  true),
  ('EMPLOYEE',        false, true),
  ('INTERN',          false, true),
  ('STUDENT',         false, true)
ON CONFLICT (role) DO NOTHING;

-- ── 2. SYNC role_menu_access — add missing menu keys ──────────
-- These were added to the frontend over several releases but the
-- backend's resolveMenuAccess() only recognized the original menu
-- list, silently dropping unknown keys (including for STUDENT,
-- which had no entry at all and fell back to ["dashboard"] only).

INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
SELECT gen_random_uuid(), r.role, m.key, true
FROM
  (VALUES ('SUPER_ADMIN'),('ADMINISTRATOR'),('PROJECT_MANAGER'),('HR_MANAGER'),('EMPLOYEE'),('INTERN'),('STUDENT')) AS r(role),
  (VALUES ('task-approvals'),('working-schedule'),('exams')) AS m(key)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- Restrict task-approvals/working-schedule away from EMPLOYEE/INTERN/STUDENT
-- (they should only be visible to managers + admins)
UPDATE role_menu_access SET is_allowed = false
WHERE menu_key IN ('task-approvals','working-schedule')
  AND role IN ('EMPLOYEE','INTERN','STUDENT');

-- leave-email-config: admin/HR only
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
SELECT gen_random_uuid(), r.role, 'leave-email-config', true
FROM (VALUES ('SUPER_ADMIN'),('ADMINISTRATOR'),('HR_MANAGER')) AS r(role)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- STUDENT baseline menus (dashboard, attendance, notifications, exams)
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
SELECT gen_random_uuid(), 'STUDENT', m.key, true
FROM (VALUES ('dashboard'),('attendance'),('notifications'),('exams')) AS m(key)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

