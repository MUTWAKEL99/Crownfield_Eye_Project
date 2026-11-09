DROP DATABASE IF EXISTS crownfield_eye;
CREATE DATABASE crownfield_eye CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE crownfield_eye;

CREATE TABLE specialty (
    specialty_id   INT AUTO_INCREMENT PRIMARY KEY,
    specialty_name VARCHAR(50) NOT NULL 
);

CREATE TABLE clinician (
    clinician_id   INT AUTO_INCREMENT PRIMARY KEY,
    clinician_name VARCHAR(100) NOT NULL,
    specialty_id   INT NULL,                       -- "may have one primary specialty"
    CONSTRAINT fk_clinician_specialty FOREIGN KEY (specialty_id)
        REFERENCES specialty(specialty_id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE clinic (
    clinic_id   INT AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE patient (
    patient_id   CHAR(5)      PRIMARY KEY,         -- e.g. OP001
    patient_name VARCHAR(100) NOT NULL,
    postcode     VARCHAR(8)   NOT NULL,
    CONSTRAINT chk_patient_id CHECK (patient_id REGEXP '^OP[0-9]{3}$')
);

CREATE TABLE appointment (
    appointment_id   INT AUTO_INCREMENT PRIMARY KEY,
    patient_id       CHAR(5) NOT NULL,
    clinician_id     INT     NOT NULL,
    clinic_id        INT     NOT NULL,
    appointment_date DATE    NOT NULL,
    appointment_time TIME    NOT NULL,
    notes            VARCHAR(255),
    CONSTRAINT fk_appt_patient   FOREIGN KEY (patient_id)   REFERENCES patient(patient_id),
    CONSTRAINT fk_appt_clinician FOREIGN KEY (clinician_id) REFERENCES clinician(clinician_id),
    CONSTRAINT fk_appt_clinic    FOREIGN KEY (clinic_id)    REFERENCES clinic(clinic_id),
    CONSTRAINT uq_clinician_slot UNIQUE (clinician_id, appointment_date, appointment_time),
    CONSTRAINT chk_appt_date  CHECK (appointment_date >= '2020-01-01'),
    CONSTRAINT chk_appt_time  CHECK (appointment_time BETWEEN '08:00:00' AND '18:00:00')
);

CREATE TABLE diagnosis (
    diagnosis_id   INT AUTO_INCREMENT PRIMARY KEY,
    diagnosis_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE appointment_diagnosis (
    appointment_id INT NOT NULL,
    diagnosis_id   INT NOT NULL,
    PRIMARY KEY (appointment_id, diagnosis_id),
    CONSTRAINT fk_ad_appt FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    CONSTRAINT fk_ad_diag FOREIGN KEY (diagnosis_id)   REFERENCES diagnosis(diagnosis_id)
);

CREATE TABLE prescription (
    prescription_id   INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id    INT  NOT NULL,
    prescription_date DATE NOT NULL,
    CONSTRAINT fk_presc_appt FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id) ON DELETE CASCADE
);

CREATE TABLE medicine (
    medicine_id   INT AUTO_INCREMENT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE prescription_item (
    prescription_item_id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id      INT          NOT NULL,
    medicine_id          INT          NOT NULL,
    dose                 VARCHAR(50)  NOT NULL,
    route                VARCHAR(30)  NOT NULL,
    frequency            VARCHAR(50)  NOT NULL,
    duration             VARCHAR(30)  NOT NULL,
    CONSTRAINT fk_pi_presc FOREIGN KEY (prescription_id) REFERENCES prescription(prescription_id) ON DELETE CASCADE,
    CONSTRAINT fk_pi_med   FOREIGN KEY (medicine_id)     REFERENCES medicine(medicine_id),
    CONSTRAINT uq_presc_medicine UNIQUE (prescription_id, medicine_id),
    CONSTRAINT chk_route CHECK (route IN ('Topical (eye drop)','Intravitreal injection','Oral','Topical (ointment)'))
);

CREATE TABLE follow_up (
    followup_id    INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT         NOT NULL UNIQUE,      -- 0..1 follow-up per appointment
    due_date       DATE        NOT NULL,
    priority       VARCHAR(10) NOT NULL DEFAULT 'Routine',
    status         VARCHAR(10) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_fu_appt FOREIGN KEY (appointment_id) REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    CONSTRAINT chk_fu_priority CHECK (priority IN ('Routine','High','Urgent')),
    CONSTRAINT chk_fu_status   CHECK (status   IN ('Pending','Booked','Completed','Cancelled'))
);

-- ============================ SAMPLE DATA ============================
INSERT INTO specialty (specialty_name) VALUES
 ('Glaucoma'),('Retina'),('Cornea'),('Cataract'),('Paediatric'),
 ('Oculoplastics'),('Neuro-ophthalmology'),('Uveitis'),('Strabismus'),('Medical Retina');

INSERT INTO clinician (clinician_name, specialty_id) VALUES
 ('Dr Maya Shah',1),('Dr Leo Grant',2),('Dr Priya Nair',3),('Dr Tom Hughes',4),
 ('Dr Grace Liu',5),('Dr Omar Farouk',6),('Dr Hannah Cole',7),('Dr Samuel Adeyemi',8),
 ('Dr Rachel Moore',9),('Dr Ian Patel',10);

INSERT INTO clinic (clinic_name) VALUES
 ('City Road'),('Bedford'),('Croydon'),('Ealing'),('Stratford'),
 ('Barking'),('Kingston'),('Harrow'),('Lewisham'),('Watford');

INSERT INTO patient VALUES
 ('OP001','Amina Yusuf','NE1 4AB'),   ('OP002','Daniel Reed','N16 7QP'),
 ('OP003','Sofia Bennett','E8 2LD'),  ('OP004','Michael Okoro','SE6 3RT'),
 ('OP005','Grace Thompson','W5 2HN'), ('OP006','Yusuf Ali','E15 1AA'),
 ('OP007','Laura Evans','KT1 3QS'),   ('OP008','Kwame Mensah','SE13 6PT'),
 ('OP009','Hannah Wright','HA1 2LP'), ('OP010','Chen Wei','WD17 1DF'),
 ('OP011','Olivia Brown','IG11 7XY'), ('OP012','Peter Novak','CR0 2JS');

INSERT INTO diagnosis (diagnosis_name) VALUES
 ('Ocular hypertension'),('Diabetic macular oedema'),('Glaucoma suspect'),('Keratoconus'),
 ('Age-related cataract'),('Amblyopia'),('Ptosis'),('Optic neuritis'),
 ('Anterior uveitis'),('Wet age-related macular degeneration');

INSERT INTO medicine (medicine_name) VALUES
 ('Latanoprost'),('Timolol'),('Aflibercept'),('Sodium chloride drops'),
 ('Prednisolone acetate'),('Chloramphenicol'),('Ranibizumab'),
 ('Atropine'),('Carbomer gel'),('Brimonidine');

-- Appointments 1-5 are the original (Appendix 1) records
INSERT INTO appointment (patient_id, clinician_id, clinic_id, appointment_date, appointment_time, notes) VALUES
 ('OP001',1,1,'2026-10-05','09:00','Review IOP'),
 ('OP002',2,1,'2026-10-05','09:30','OCT before review'),
 ('OP001',1,2,'2026-11-16','10:15','Visual field test'),
 ('OP003',1,1,'2026-10-06','11:00','Monitor'),
 ('OP004',3,3,'2026-10-07','14:00','Corneal topography'),
 ('OP005',4,4,'2026-09-14','10:00','Pre-operative biometry'),
 ('OP006',5,5,'2026-09-21','13:30','Orthoptic assessment'),
 ('OP007',6,7,'2026-09-28','15:00','Lid assessment'),
 ('OP008',7,9,'2026-10-12','09:45','Colour vision and fields'),
 ('OP009',8,8,'2026-10-13','11:30','Anterior chamber cells 2+'),
 ('OP010',10,10,'2026-10-19','10:30','Anti-VEGF loading dose'),
 ('OP002',2,1,'2026-11-02','09:30','Post-injection review'),
 ('OP011',9,6,'2026-11-03','14:30','Squint review - no new findings'),
 ('OP012',4,3,'2026-11-04','16:00','Routine cataract review'),
 ('OP003',1,2,'2026-11-05','11:00','Repeat IOP check');

INSERT INTO appointment_diagnosis VALUES
 (1,1),(2,2),(3,1),(4,3),(5,4),(6,5),(7,6),(8,7),(9,8),(10,9),(11,10),(12,2),(15,3);
 -- appointments 13 and 14 have no diagnosis recorded (optional 0..*)

INSERT INTO prescription (appointment_id, prescription_date) VALUES
 (1,'2026-10-05'),(2,'2026-10-05'),(3,'2026-11-16'),(5,'2026-10-07'),
 (6,'2026-09-14'),(7,'2026-09-21'),(8,'2026-09-28'),(9,'2026-10-12'),
 (10,'2026-10-13'),(11,'2026-10-19'),(12,'2026-11-02');
 -- appointment 4 (OP003 "None"), 13, 14 and 15 have no prescription

INSERT INTO prescription_item (prescription_id, medicine_id, dose, route, frequency, duration) VALUES
 (1,1,'1 drop (0.005%)','Topical (eye drop)','Once daily at night','6 weeks'),
 (1,2,'1 drop (0.5%)','Topical (eye drop)','Twice daily','6 weeks'),
 (2,3,'2 mg','Intravitreal injection','Single dose','1 day'),
 (3,1,'1 drop (0.005%)','Topical (eye drop)','Once daily at night','12 weeks'),
 (4,4,'1 drop (5%)','Topical (eye drop)','Four times daily','8 weeks'),
 (5,6,'1 drop (0.5%)','Topical (eye drop)','Four times daily','1 week'),
 (6,8,'1 drop (1%)','Topical (eye drop)','Twice weekly','12 weeks'),
 (7,9,'1 application','Topical (ointment)','At night','4 weeks'),
 (8,5,'1 drop (1%)','Topical (eye drop)','Hourly then taper','4 weeks'),
 (9,5,'1 drop (1%)','Topical (eye drop)','Four times daily','6 weeks'),
 (10,7,'0.5 mg','Intravitreal injection','Single dose','1 day'),
 (11,3,'2 mg','Intravitreal injection','Single dose','1 day'),
 (11,10,'1 drop (0.2%)','Topical (eye drop)','Twice daily','2 weeks');

INSERT INTO follow_up (appointment_id, due_date, priority, status) VALUES
 (1,'2026-11-16','High','Booked'),
 (2,'2026-11-02','Urgent','Completed'),
 (3,'2027-02-08','Routine','Pending'),
 (4,'2027-04-06','Routine','Pending'),
 (5,'2026-12-02','Routine','Pending'),
 (6,'2026-10-12','High','Completed'),
 (7,'2026-10-19','Routine','Pending'),
 (8,'2026-10-26','Routine','Cancelled'),
 (9,'2026-10-26','Urgent','Pending'),
 (10,'2026-10-27','High','Pending'),
 (11,'2026-11-16','Urgent','Booked'),
 (12,'2026-11-30','Urgent','Pending');