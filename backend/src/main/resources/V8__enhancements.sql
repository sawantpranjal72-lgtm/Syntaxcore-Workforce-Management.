-- Align Java Double fields with Hibernate's PostgreSQL validation type.
-- Existing numeric values are preserved while the columns are converted.

ALTER TABLE attendance
    ALTER COLUMN total_hours TYPE DOUBLE PRECISION USING total_hours::DOUBLE PRECISION;

ALTER TABLE projects
    ALTER COLUMN budget TYPE DOUBLE PRECISION USING budget::DOUBLE PRECISION;

ALTER TABLE tasks
    ALTER COLUMN estimated_hours TYPE DOUBLE PRECISION USING estimated_hours::DOUBLE PRECISION,
    ALTER COLUMN actual_hours TYPE DOUBLE PRECISION USING actual_hours::DOUBLE PRECISION;

ALTER TABLE work_logs
    ALTER COLUMN hours_worked TYPE DOUBLE PRECISION USING hours_worked::DOUBLE PRECISION;
