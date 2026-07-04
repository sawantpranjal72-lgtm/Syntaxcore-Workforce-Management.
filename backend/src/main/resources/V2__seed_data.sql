-- ============================================================
-- V18: Attendance — GPS location coordinates + live photos
--
-- Adds per-event (check-in and check-out) GPS coordinates,
-- human-readable location labels, and selfie photo storage so
-- that the daily attendance report can show where and who
-- checked in/out, providing a verifiable attendance record.
-- ============================================================

ALTER TABLE attendance
    ADD COLUMN IF NOT EXISTS check_in_latitude   DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS check_in_longitude  DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS check_in_location   VARCHAR(500),
    ADD COLUMN IF NOT EXISTS check_in_photo      TEXT,
    ADD COLUMN IF NOT EXISTS check_out_latitude  DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS check_out_longitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS check_out_location  VARCHAR(500),
    ADD COLUMN IF NOT EXISTS check_out_photo     TEXT;
