-- ============================================================
-- V15: Instructor-graded exam scoring
--
-- Exam marks were previously system-finalized at submit time
-- (auto-graded MCQ only; SHORT/LONG/CODING silently scored 0,
-- and pass/fail was decided immediately with no human review).
-- This migration adds the columns needed for an instructor —
-- specifically, anyone with exam-management permission — to
-- review each candidate's actual answers question-by-question
-- and assign the real marks before a result is considered final.
-- ============================================================

ALTER TABLE exam_attempts
    ADD COLUMN IF NOT EXISTS question_scores_json   TEXT,            -- {"q1": 2, "q2": 0, ...} marks awarded per question
    ADD COLUMN IF NOT EXISTS question_feedback_json  TEXT,            -- {"q1": "Good answer", ...} optional per-question remarks
    ADD COLUMN IF NOT EXISTS instructor_feedback     TEXT,            -- overall feedback for the attempt
    ADD COLUMN IF NOT EXISTS graded_by_id            UUID REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS graded_at               TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_attempt_status ON exam_attempts(status);

-- Existing SUBMITTED attempts (auto-scored under the old behavior) are left
-- as-is; their status remains SUBMITTED until an instructor opens and grades
-- them, at which point status moves to GRADED and the score becomes final.
