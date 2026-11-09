-- =============================================
-- CROWNFIELD EYE — ALL 6 QUERIES
-- =============================================
USE crownfield_eye;

-- QUERY 1: Patients with more than 1 appointment
SELECT
    p.patient_id,
    p.full_name,
    COUNT(a.appointment_id) AS total_appointments
FROM Patient p
INNER JOIN Appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.full_name
HAVING COUNT(a.appointment_id) > 1;

-- QUERY 2: Multiple INNER JOINs
SELECT
    a.appointment_id,
    p.full_name AS patient_name,
    c.full_name AS clinician_name,
    cl.clinic_name,
    a.appointment_date,
    a.status
FROM Appointment a
INNER JOIN Patient p ON a.patient_id = p.patient_id
INNER JOIN Clinician c ON a.clinician_id = c.clinician_id
INNER JOIN Clinic cl ON a.clinic_id = cl.clinic_id;

-- QUERY 3: LEFT JOIN
SELECT
    p.patient_id,
    p.full_name,
    COUNT(a.appointment_id) AS total_appointments
FROM Patient p
LEFT JOIN Appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.full_name;

-- QUERY 4: CTE + Average
WITH PatientAppointments AS (
    SELECT p.patient_id, p.full_name,
           COUNT(a.appointment_id) AS appt_count
    FROM Patient p
    LEFT JOIN Appointment a ON p.patient_id = a.patient_id
    GROUP BY p.patient_id, p.full_name
)
SELECT patient_id, full_name, appt_count,
       (SELECT AVG(appt_count) FROM PatientAppointments) AS average_count
FROM PatientAppointments;

-- QUERY 5: Stored Procedure
DROP PROCEDURE IF EXISTS GetPatientAppointments;
CREATE PROCEDURE GetPatientAppointments(IN p_patient_id INT)
SELECT 
    a.appointment_id, a.appointment_date, a.start_time,
    c.full_name AS clinician_name, cl.clinic_name, a.status
FROM Appointment a
INNER JOIN Clinician c ON a.clinician_id = c.clinician_id
INNER JOIN Clinic cl ON a.clinic_id = cl.clinic_id
WHERE a.patient_id = p_patient_id
ORDER BY a.appointment_date;

-- Run the procedure:
-- CALL GetPatientAppointments(1);

-- QUERY 6: Trigger
DROP TRIGGER IF EXISTS trg_appointment_status_change;
CREATE TRIGGER trg_appointment_status_change
AFTER UPDATE ON Appointment
FOR EACH ROW
INSERT INTO AppointmentAudit (appointment_id, change_type, old_status, new_status)
VALUES (NEW.appointment_id, 'STATUS_CHANGE', OLD.status, NEW.status);

-- Test the trigger:
-- UPDATE Appointment SET status = 'Follow-up Required' WHERE appointment_id = 1;
-- SELECT * FROM AppointmentAudit;
