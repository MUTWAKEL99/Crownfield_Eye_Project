USE crownfield_eye;

-- =============================================
-- TRANSACTION 1: COMMIT
-- All changes saved permanently
-- =============================================
START TRANSACTION;

INSERT INTO Appointment
    (patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes)
VALUES
    ('OP001', 1, 1, '2026-11-10', '09:30:00', 'Initial consultation');

SET @new_appt = LAST_INSERT_ID();

SELECT 'Before Commit' AS Stage, COUNT(*) AS Rows_Found
FROM Appointment WHERE appointment_id = @new_appt;

COMMIT;

SELECT 'After Commit' AS Stage, COUNT(*) AS Rows_Found
FROM Appointment WHERE appointment_id = @new_appt;

-- Screenshot above → Transaction1_Commit.png ✅

-- =============================================
-- TRANSACTION 2: ROLLBACK
-- All changes undone — nothing saved
-- =============================================
START TRANSACTION;

INSERT INTO Appointment
    (patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes)
VALUES
    ('OP001', 1, 1, '2026-12-01', '10:15:00', 'Rollback test appointment');

SET @test_appt = LAST_INSERT_ID();

SELECT 'Before Rollback' AS Stage, COUNT(*) AS Rows_Found
FROM Appointment WHERE appointment_id = @test_appt;

ROLLBACK;

SELECT 'After Rollback' AS Stage, COUNT(*) AS Rows_Found
FROM Appointment WHERE appointment_id = @test_appt;

-- Screenshot above → Transaction2_Rollback.png ✅
