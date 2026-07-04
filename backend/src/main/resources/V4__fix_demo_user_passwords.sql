-- ============================================================
-- SyntaxCore Workforce Management System
-- V2 — Department & Role Seed Data
-- NOTE: No demo user credentials are seeded in production.
--       Create the first Super Admin via the /api/v1/auth/setup endpoint.
-- ============================================================

-- ─── DEPARTMENTS ────────────────────────────────────────────
INSERT INTO departments (id, name, code, description, is_active)
VALUES
  ('11111111-0000-0000-0000-000000000001', 'Engineering',       'ENG', 'Software Engineering & Development', TRUE),
  ('11111111-0000-0000-0000-000000000002', 'Design',            'DES', 'UI/UX and Product Design',           TRUE),
  ('11111111-0000-0000-0000-000000000003', 'Human Resources',   'HR',  'HR and Talent Management',           TRUE),
  ('11111111-0000-0000-0000-000000000004', 'Product Management','PM',  'Product Strategy and Roadmap',       TRUE),
  ('11111111-0000-0000-0000-000000000005', 'QA & Testing',      'QA',  'Quality Assurance and Testing',      TRUE),
  ('11111111-0000-0000-0000-000000000006', 'Finance',           'FIN', 'Finance and Accounting',             TRUE),
  ('11111111-0000-0000-0000-000000000007', 'Operations',        'OPS', 'Operations and Infrastructure',      TRUE)
ON CONFLICT (id) DO NOTHING;
