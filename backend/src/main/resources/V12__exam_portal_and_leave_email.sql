-- ============================================================
-- V10: Fix task_assignees, add task-approvals to role_menu_access
-- ============================================================

-- 1. Ensure task_assignees join table exists with proper CASCADE
CREATE TABLE IF NOT EXISTS task_assignees (
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (task_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_task_assignees_task_v2 ON task_assignees(task_id);
CREATE INDEX IF NOT EXISTS idx_task_assignees_user_v2 ON task_assignees(user_id);

-- 2. Add task-approvals menu access for managers
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',     'task-approvals', true),
  (gen_random_uuid(), 'ADMINISTRATOR',   'task-approvals', true),
  (gen_random_uuid(), 'PROJECT_MANAGER', 'task-approvals', true),
  (gen_random_uuid(), 'HR_MANAGER',      'task-approvals', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- 3. Add working-schedule menu access for admins
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',   'working-schedule', true),
  (gen_random_uuid(), 'ADMINISTRATOR', 'working-schedule', true),
  (gen_random_uuid(), 'HR_MANAGER',    'working-schedule', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

-- 4. Ensure my-tasks is allowed for all roles
INSERT INTO role_menu_access (id, role, menu_key, is_allowed)
VALUES
  (gen_random_uuid(), 'SUPER_ADMIN',     'my-tasks', true),
  (gen_random_uuid(), 'ADMINISTRATOR',   'my-tasks', true),
  (gen_random_uuid(), 'PROJECT_MANAGER', 'my-tasks', true),
  (gen_random_uuid(), 'HR_MANAGER',      'my-tasks', true),
  (gen_random_uuid(), 'EMPLOYEE',        'my-tasks', true),
  (gen_random_uuid(), 'INTERN',          'my-tasks', true)
ON CONFLICT (role, menu_key) DO UPDATE SET is_allowed = true, is_deleted = false;

