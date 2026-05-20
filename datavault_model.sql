CREATE TABLE hub_patient (
    patient_hk SERIAL PRIMARY KEY,
    patient_bk VARCHAR(50) UNIQUE NOT NULL,
    load_date TIMESTAMP DEFAULT NOW(),
    record_source VARCHAR(50)
);

CREATE TABLE hub_doctor (
    doctor_hk SERIAL PRIMARY KEY,
    doctor_bk VARCHAR(50) UNIQUE NOT NULL,
    load_date TIMESTAMP DEFAULT NOW(),
    record_source VARCHAR(50)
);

CREATE TABLE hub_diagnosis (
    diagnosis_hk SERIAL PRIMARY KEY,
    diagnosis_bk VARCHAR(50) UNIQUE NOT NULL,
    load_date TIMESTAMP DEFAULT NOW(),
    record_source VARCHAR(50)
);

CREATE TABLE hub_room (
    room_hk SERIAL PRIMARY KEY,
    room_bk VARCHAR(50) UNIQUE NOT NULL,
    load_date TIMESTAMP DEFAULT NOW(),
    record_source VARCHAR(50)
);

CREATE TABLE link_admission (
    admission_hk SERIAL PRIMARY KEY,

    patient_hk INT REFERENCES hub_patient(patient_hk),

    doctor_hk INT REFERENCES hub_doctor(doctor_hk),

    diagnosis_hk INT REFERENCES hub_diagnosis(diagnosis_hk),

    room_hk INT REFERENCES hub_room(room_hk),

    load_date TIMESTAMP DEFAULT NOW(),
    record_source VARCHAR(50)
);

CREATE TABLE sat_patient_details (
    patient_hk INT REFERENCES hub_patient(patient_hk),

    full_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    phone VARCHAR(20),
    address TEXT,

    load_date TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (patient_hk, load_date)
);

CREATE TABLE sat_doctor_details (
    doctor_hk INT REFERENCES hub_doctor(doctor_hk),

    full_name VARCHAR(100),
    specialization VARCHAR(100),
    phone VARCHAR(20),

    load_date TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (doctor_hk, load_date)
);


CREATE TABLE sat_diagnosis_details (
    diagnosis_hk INT REFERENCES hub_diagnosis(diagnosis_hk),

    diagnosis_name VARCHAR(200),
    description TEXT,

    load_date TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (diagnosis_hk, load_date)
);


CREATE TABLE sat_room_details (
    room_hk INT REFERENCES hub_room(room_hk),

    room_number VARCHAR(10),
    room_type VARCHAR(50),
    capacity INT,

    load_date TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (room_hk, load_date)
);

INSERT INTO hub_patient
(patient_bk, record_source)
VALUES
('PAT001', 'HospitalSystem');

INSERT INTO sat_patient_details
(patient_hk, full_name, birth_date,
 gender, phone, address)
VALUES
(1, 'Sergey Ivanov',
 '1990-05-12',
 'Male',
 '+79995554433',
 'Moscow');

