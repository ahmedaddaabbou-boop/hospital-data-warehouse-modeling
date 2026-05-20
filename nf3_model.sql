CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    phone VARCHAR(20),
    department_id INT REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    gender VARCHAR(10),
    phone VARCHAR(20),
    address TEXT
);

CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(10),
    room_type VARCHAR(50),
    capacity INT
);

CREATE TABLE diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    diagnosis_name VARCHAR(200) NOT NULL,
    description TEXT
);

CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    doctor_id INT REFERENCES doctors(doctor_id),
    room_id INT REFERENCES rooms(room_id),
    diagnosis_id INT REFERENCES diagnoses(diagnosis_id),
    admission_date TIMESTAMP NOT NULL,
    discharge_date TIMESTAMP,
    status VARCHAR(50)
);

INSERT INTO departments (department_name)
VALUES
('Cardiology'),
('Neurology'),
('Traumatology');

INSERT INTO doctors
(full_name, specialization, phone, department_id)
VALUES
('Ivan Petrov', 'Cardiologist', '+79990001111', 1),
('Anna Sidorova', 'Neurologist', '+79990002222', 2);


INSERT INTO patients
(full_name, birth_date, gender, phone, address)
VALUES
('Sergey Ivanov', '1990-05-12', 'Male',
 '+79995554433', 'Moscow'),

('Maria Petrova', '1985-08-21', 'Female',
 '+79995556677', 'Saint Petersburg');

INSERT INTO rooms
(room_number, room_type, capacity)
VALUES
('101', 'Emergency', 2),
('202', 'Standard', 4);


INSERT INTO diagnoses
(diagnosis_name, description)
VALUES
('Hypertension', 'High blood pressure'),
('Concussion', 'Brain injury');

INSERT INTO admissions
(patient_id, doctor_id, room_id,
 diagnosis_id, admission_date,
 discharge_date, status)
VALUES
(1, 1, 1, 1,
 NOW(), NULL, 'Under treatment'),

(2, 2, 2, 2,
 NOW(), NULL, 'Observation');


# all admissions
SELECT
    a.admission_id,
    p.full_name AS patient,
    d.full_name AS doctor,
    dg.diagnosis_name,
    a.status
FROM admissions a
JOIN patients p
    ON a.patient_id = p.patient_id
JOIN doctors d
    ON a.doctor_id = d.doctor_id
JOIN diagnoses dg
    ON a.diagnosis_id = dg.diagnosis_id;

# Patients by diagnosis
SELECT
    dg.diagnosis_name,
    COUNT(*) AS total_patients
FROM admissions a
JOIN diagnoses dg
    ON a.diagnosis_id = dg.diagnosis_id
GROUP BY dg.diagnosis_name;

