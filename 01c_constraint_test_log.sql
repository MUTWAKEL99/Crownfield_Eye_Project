USE crownfield_eye;

DROP TABLE IF EXISTS test_log;
CREATE TABLE test_log (
    test_id     VARCHAR(4)   PRIMARY KEY,
    constraint_tested VARCHAR(20),
    test_description  VARCHAR(80),
    expected    VARCHAR(20),
    actual      VARCHAR(160),
    result      VARCHAR(4)
);

DROP PROCEDURE IF EXISTS run_test;
DELIMITER //
CREATE PROCEDURE run_test(IN p_id VARCHAR(4), IN p_constraint VARCHAR(20),
                          IN p_desc VARCHAR(80), IN p_sql TEXT)
BEGIN
    DECLARE v_errno INT;
    DECLARE v_msg   VARCHAR(160);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        INSERT INTO test_log VALUES (p_id, p_constraint, p_desc, 'Rejected',
                                     CONCAT('Error ', v_errno, ': ', LEFT(v_msg, 75)), 'PASS');
    END;

    SET @t = p_sql;
    PREPARE stmt FROM @t;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    -- reaching this line means the bad data was ACCEPTED -> test fails
    INSERT INTO test_log VALUES (p_id, p_constraint, p_desc, 'Rejected', 'Accepted (no error)', 'FAIL');
END //
DELIMITER ;

CALL run_test('T1','FOREIGN KEY','Appointment for non-existent patient OP999',
  "INSERT INTO appointment (patient_id, clinician_id, clinic_id, appointment_date, appointment_time) VALUES ('OP999',1,1,'2026-12-01','10:00')");
CALL run_test('T2','CHECK','Follow-up status ''Lost'' (not an allowed value)',
  "INSERT INTO follow_up (appointment_id, due_date, priority, status) VALUES (14,'2027-01-10','Routine','Lost')");
CALL run_test('T3','UNIQUE','Dr Shah double-booked 05/10/2026 09:00',
  "INSERT INTO appointment (patient_id, clinician_id, clinic_id, appointment_date, appointment_time) VALUES ('OP005',1,1,'2026-10-05','09:00')");
CALL run_test('T4','CHECK','Patient ID in wrong format (P1)',
  "INSERT INTO patient VALUES ('P1','Test Person','AB1 2CD')");
CALL run_test('T5','NOT NULL','Patient with no name',
  "INSERT INTO patient VALUES ('OP050', NULL, 'AB1 2CD')");
CALL run_test('T6','FK (delete)','Delete patient OP001 who has appointments',
  "DELETE FROM patient WHERE patient_id = 'OP001'");


SELECT * FROM test_log ORDER BY test_id;


DROP PROCEDURE run_test;

