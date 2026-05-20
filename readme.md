# 🏥 Hospital Emergency Room — Database Design Lab

> **Lab Work** | Databases Discipline | Variant 10  
> **Topic:** Information system for a hospital emergency room (приёмный покой)  
> **DBMS:** PostgreSQL  
> **Models implemented:** 3NF (Third Normal Form) · Data Vault

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [3NF Model](#3nf-model)
- [Data Vault Model](#data-vault-model)
- [How to Run](#how-to-run)
- [Sample Queries](#sample-queries)

---

## Overview

This project implements a database for a hospital emergency room in two modeling methodologies:

| Aspect | 3NF | Data Vault |
|---|---|---|
| Purpose | OLTP (transactional) | DWH (analytics + history) |
| Redundancy | Minimal | Higher (by design) |
| History tracking | No | Full (via `load_date`) |
| Query complexity | Simple JOINs | Multi-level JOINs |
| Scalability | Medium | High |
| Audit trail | Limited | Built-in (`record_source`) |

---

## Project Structure

```
hospital-db/
├── nf3_model.sql          # 3NF schema: tables, inserts, queries
├── datavault_model.sql    # Data Vault schema: hubs, links, satellites
└── README.md
```

---

## 3NF Model

### Entity-Relationship Overview

```
departments ──< doctors ──< admissions >── patients
                                │
                           rooms ──────────┘
                           diagnoses ──────┘
```

### Tables

| Table | Description |
|---|---|
| `departments` | Hospital departments (Cardiology, Neurology, etc.) |
| `doctors` | Doctors with specialization, linked to a department |
| `patients` | Patient personal data |
| `rooms` | Hospital rooms with type and capacity |
| `diagnoses` | Diagnosis reference book |
| `admissions` | **Central fact table** — links patient, doctor, room, diagnosis |

---

## Data Vault Model

### Architecture

```
hub_patient ──┐
hub_doctor  ──┤
              ├──> link_admission
hub_room    ──┤
hub_diagnosis─┘

hub_patient   <──> sat_patient_details
hub_doctor    <──> sat_doctor_details
hub_room      <──> sat_room_details
hub_diagnosis <──> sat_diagnosis_details
```

### Components

**Hubs** — store unique business keys only:
- `hub_patient` · `hub_doctor` · `hub_diagnosis` · `hub_room`

**Link** — stores the admission relationship:
- `link_admission` — connects all four hubs

**Satellites** — store descriptive attributes with full history:
- `sat_patient_details` · `sat_doctor_details` · `sat_diagnosis_details` · `sat_room_details`

> History is tracked via composite PK: `(hub_key, load_date)` — every change creates a new row instead of overwriting.

---

## How to Run

### Prerequisites

- PostgreSQL 13+ installed and running
- `psql` CLI or pgAdmin / VS Code with PostgreSQL extension

### Option 1 — psql CLI

```bash
# Create two separate databases
psql -U postgres -c "CREATE DATABASE hospital_3nf;"
psql -U postgres -c "CREATE DATABASE hospital_datavault;"

# Run the scripts
psql -U postgres -d hospital_3nf      -f nf3_model.sql
psql -U postgres -d hospital_datavault -f datavault_model.sql
```

### Option 2 — VS Code (PostgreSQL extension)

1. Open `nf3_model.sql` or `datavault_model.sql`
2. Connect to your PostgreSQL server via the Explorer panel
3. Select all (`Ctrl+A`) and run (`F5` or right-click → *Run Query*)

---

## Sample Queries

### 3NF — All active admissions

```sql
SELECT
    a.admission_id,
    p.full_name      AS patient,
    d.full_name      AS doctor,
    dg.diagnosis_name,
    a.status
FROM admissions a
JOIN patients  p  ON a.patient_id   = p.patient_id
JOIN doctors   d  ON a.doctor_id    = d.doctor_id
JOIN diagnoses dg ON a.diagnosis_id = dg.diagnosis_id;
```

### 3NF — Patient count by diagnosis

```sql
SELECT
    dg.diagnosis_name,
    COUNT(*) AS total_patients
FROM admissions a
JOIN diagnoses dg ON a.diagnosis_id = dg.diagnosis_id
GROUP BY dg.diagnosis_name
ORDER BY total_patients DESC;
```

### Data Vault — Current state (latest attribute version)

```sql
SELECT
    sp.full_name        AS patient_name,
    sd.full_name        AS doctor_name,
    sd.specialization,
    sdiag.diagnosis_name,
    sr.room_number,
    la.load_date        AS admission_date
FROM link_admission la
JOIN hub_patient    hp    ON la.patient_hk   = hp.patient_hk
JOIN hub_doctor     hd    ON la.doctor_hk    = hd.doctor_hk
JOIN hub_diagnosis  hdiag ON la.diagnosis_hk = hdiag.diagnosis_hk
JOIN hub_room       hr    ON la.room_hk      = hr.room_hk
JOIN sat_patient_details sp
    ON sp.patient_hk = hp.patient_hk
   AND sp.load_date  = (SELECT MAX(load_date) FROM sat_patient_details WHERE patient_hk = hp.patient_hk)
JOIN sat_doctor_details sd
    ON sd.doctor_hk  = hd.doctor_hk
   AND sd.load_date  = (SELECT MAX(load_date) FROM sat_doctor_details WHERE doctor_hk = hd.doctor_hk)
JOIN sat_diagnosis_details sdiag
    ON sdiag.diagnosis_hk = hdiag.diagnosis_hk
   AND sdiag.load_date    = (SELECT MAX(load_date) FROM sat_diagnosis_details WHERE diagnosis_hk = hdiag.diagnosis_hk)
JOIN sat_room_details sr
    ON sr.room_hk   = hr.room_hk
   AND sr.load_date = (SELECT MAX(load_date) FROM sat_room_details WHERE room_hk = hr.room_hk);
```

---

*Лабораторная работа по дисциплине «Базы данных» · Вариант 10*