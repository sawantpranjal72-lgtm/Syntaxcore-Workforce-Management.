-- V4 — Role migration: rename old roles to new standard roles
-- Maps HR_ADMIN -> HR_MANAGER, TEAM_LEAD -> PROJECT_MANAGER for backwards compat

UPDATE users SET role = 'HR_MANAGER'      WHERE role = 'HR_ADMIN'   AND is_deleted = FALSE;
UPDATE users SET role = 'PROJECT_MANAGER' WHERE role = 'TEAM_LEAD'  AND is_deleted = FALSE;
