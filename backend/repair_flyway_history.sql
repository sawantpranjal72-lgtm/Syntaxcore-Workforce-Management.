-- ============================================================
-- SyntaxCore WMS — Flyway Schema History Repair Script
-- ============================================================
-- Run this SQL directly against your PostgreSQL database when
-- Flyway fails to start because some rows in flyway_schema_history
-- were accidentally deleted.
--
-- HOW TO USE:
--   1. Stop the backend application if it's running.
--   2. Connect to your database:
--        psql -U your_user -d your_database
--   3. Run this file:
--        \i repair_flyway_history.sql
--   4. Start the backend — Flyway will see the history rows and
--      skip the already-applied migrations cleanly.
--
-- SAFETY: Every INSERT uses ON CONFLICT DO NOTHING, so re-running
-- this script multiple times is completely safe.
--
-- IMPORTANT: If your migration files have been modified since they
-- were first applied, the checksum values below won't match what
-- Flyway calculates from the current file content. In that case,
-- also run:  CALL flyway_repair();  — or set
-- spring.flyway.repair-on-migrate=true temporarily in
-- application.yml, which auto-corrects mismatched checksums.
-- ============================================================

-- Ensure the history table exists (Flyway creates it on first run,
-- but if it was fully dropped you need a clean start instead).
CREATE TABLE IF NOT EXISTS flyway_schema_history (
    installed_rank  INTEGER      NOT NULL,
    version         VARCHAR(50),
    description     VARCHAR(200) NOT NULL,
    type            VARCHAR(20)  NOT NULL,
    script          VARCHAR(1000) NOT NULL,
    checksum        INTEGER,
    installed_by    VARCHAR(100) NOT NULL,
    installed_on    TIMESTAMP    NOT NULL DEFAULT now(),
    execution_time  INTEGER      NOT NULL,
    success         BOOLEAN      NOT NULL,
    CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank)
);

-- ──────────────────────────────────────────────────────────────
-- Insert each migration row if it's missing.
-- installed_rank must be sequential (determines apply order).
-- checksum values are CRC32 of the exact file bytes in this build.
-- ──────────────────────────────────────────────────────────────

INSERT INTO flyway_schema_history
    (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success)
VALUES
    (1,  '1',  'initial schema',                     'SQL', 'V1__initial_schema.sql',                     -1147008531,  'postgres', now(), 1000, TRUE),
    (2,  '2',  'seed data',                           'SQL', 'V2__seed_data.sql',                           -175707819,   'postgres', now(), 100,  TRUE),
    (3,  '3',  'otp sessions leaves',                 'SQL', 'V3__otp_sessions_leaves.sql',                 1602314985,   'postgres', now(), 200,  TRUE),
    (4,  '4',  'fix demo user passwords',             'SQL', 'V4__fix_demo_user_passwords.sql',             -1138493819,  'postgres', now(), 50,   TRUE),
    (5,  '5',  'production setup',                    'SQL', 'V5__production_setup.sql',                    1996919720,   'postgres', now(), 100,  TRUE),
    (6,  '6',  'align double columns for validate',   'SQL', 'V6__align_double_columns_for_validate.sql',   -1589655997,  'postgres', now(), 50,   TRUE),
    (7,  '7',  'access control settings',             'SQL', 'V7__access_control_settings.sql',             1586217538,   'postgres', now(), 100,  TRUE),
    (8,  '8',  'enhancements',                        'SQL', 'V8__enhancements.sql',                        1312659983,   'postgres', now(), 200,  TRUE),
    (9,  '9',  'notification routing',                'SQL', 'V9__notification_routing.sql',                1979109780,   'postgres', now(), 100,  TRUE),
    (10, '10', 'fix task assignees and access',       'SQL', 'V10__fix_task_assignees_and_access.sql',      5421106,      'postgres', now(), 100,  TRUE),
    (11, '11', 'work schedule task assignees',        'SQL', 'V11__work_schedule_task_assignees.sql',       -1376001607,  'postgres', now(), 100,  TRUE),
    (12, '12', 'exam portal and leave email',         'SQL', 'V12__exam_portal_and_leave_email.sql',        981919908,    'postgres', now(), 300,  TRUE),
    (13, '13', 'exam permissions and menu sync',      'SQL', 'V13__exam_permissions_and_menu_sync.sql',     648804445,    'postgres', now(), 100,  TRUE),
    (14, '14', 'remove notification user id',         'SQL', 'V14__remove_notification_user_id.sql',        -2144171750,  'postgres', now(), 50,   TRUE),
    (15, '15', 'exam instructor grading',             'SQL', 'V15__exam_instructor_grading.sql',            -1474736219,  'postgres', now(), 100,  TRUE),
    (16, '16', 'task started by',                    'SQL', 'V16__task_started_by.sql',                    -1474771086,  'postgres', now(), 50,   TRUE),
    (17, '17', 'leave email action token',            'SQL', 'V17__leave_email_action_token.sql',           1002547055,   'postgres', now(), 50,   TRUE)
ON CONFLICT (installed_rank) DO NOTHING;

-- ──────────────────────────────────────────────────────────────
-- Verification: show what's now in the history table.
-- All 17 rows should appear with success = TRUE.
-- ──────────────────────────────────────────────────────────────
SELECT installed_rank, version, description, success, installed_on
FROM   flyway_schema_history
ORDER  BY installed_rank;
