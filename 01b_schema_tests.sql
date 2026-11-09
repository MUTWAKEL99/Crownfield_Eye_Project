USE crownfield_eye;

-- T0: Row counts - every main table holds at least 10 records
SELECT 'patient' AS table_name, COUNT(*) AS row_count FROM patient
UNION ALL SELECT 'clinician',  COUNT(*) FROM clinician
UNION ALL SELECT 'clinic',     COUNT(*) FROM clinic
UNION ALL SELECT 'specialty',  COUNT(*) FROM specialty
UNION ALL SELECT 'appointment',COUNT(*) FROM appointment
UNION ALL SELECT 'diagnosis',  COUNT(*) FROM diagnosis
UNION ALL SELECT 'medicine',   COUNT(*) FROM medicine
UNION ALL SELECT 'prescription',      COUNT(*) FROM prescription
UNION ALL SELECT 'prescription_item', COUNT(*) FROM prescription_item
UNION ALL SELECT 'follow_up',  COUNT(*) FROM follow_up;

-- T1 FOREIGN KEY: appointment for a patient that does not exist -> EXPECT error 1452
INSERT INTO appointment (patient_id, clinician_id, clinic_id, appointment_date, appointment_time)
VALUES ('OP999', 1, 1, '2026-12-01', '10:00');

-- T2 CHECK: invalid follow-up status -> EXPECT error 3819
INSERT INTO follow_up (appointment_id, due_date, priority, status)
VALUES (14, '2027-01-10', 'Routine', 'Lost');

-- T3 UNIQUE: same clinician double-booked in the same slot -> EXPECT error 1062
INSERT INTO appointment (patient_id, clinician_id, clinic_id, appointment_date, appointment_time)
VALUES ('OP005', 1, 1, '2026-10-05', '09:00');

-- T4 CHECK: patient ID in wrong format -> EXPECT error 3819
INSERT INTO patient VALUES ('P1', 'Test Person', 'AB1 2CD');

-- T5 NOT NULL: patient without a name -> EXPECT error 1048
INSERT INTO patient VALUES ('OP050', NULL, 'AB1 2CD');

-- T6 Referential integrity on DELETE: patient OP001 has appointments -> EXPECT error 1451
DELETE FROM patient WHERE patient_id = 'OP001';

-- T7 DEFAULT: priority and status not supplied -> EXPECT 'Routine' / 'Pending'
INSERT INTO follow_up (appointment_id, due_date) VALUES (14, '2027-02-01');
SELECT followup_id, appointment_id, due_date, priority, status
FROM follow_up WHERE appointment_id = 14;
DELETE FROM follow_up WHERE appointment_id = 14;     -- remove test row

-- ---------------------------------------------------------------------
-- Controlled UPDATE: patient OP012 moved house - change ONE row by primary key
-- ---------------------------------------------------------------------
SELECT patient_id, patient_name, postcode FROM patient WHERE patient_id = 'OP012';
UPDATE patient SET postcode = 'CR2 6XH' WHERE patient_id = 'OP012';
SELECT patient_id, patient_name, postcode FROM patient WHERE patient_id = 'OP012';
UPDATE patient SET postcode = 'CR0 2JS' WHERE patient_id = 'OP012';
-- ---------------------------------------------------------------------
-- Controlled DELETE: a duplicate patient record was created in error
-- (the type of redundancy found in the unnormalised data). It has no
-- appointments, so it can be removed without orphaning any rows.
-- ---------------------------------------------------------------------
INSERT INTO patient VALUES ('OP013', 'Amina Yusuf', 'NE1 4AB');      -- duplicate entered by mistake
SELECT p.patient_id, p.patient_name, COUNT(a.appointment_id) AS appointments
FROM patient p LEFT JOIN appointment a ON a.patient_id = p.patient_id
WHERE p.patient_name = 'Amina Yusuf' GROUP BY p.patient_id, p.patient_name;

DELETE FROM patient
WHERE  patient_id = 'OP013'
  AND  NOT EXISTS (SELECT 1 FROM appointment a WHERE a.patient_id = 'OP013');

SELECT patient_id, patient_name FROM patient WHERE patient_name = 'Amina Yusuf';
