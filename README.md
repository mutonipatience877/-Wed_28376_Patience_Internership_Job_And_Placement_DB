# Internship & Job Placement System

This repository contains the full deliverables for the University Internship & Job Placement project, organized into three phases aligned with MIS best practices.

## Repository Structure
```
/ (root)
├── images/
|   |.... Wed_28376_Patience_PLSQL.pdf
│   ├── bpm_diagram.png         # BPMN Business Process Model
│   ├── logical_model.png       # Logical ER model
│   ├── functions.png           # Functions code sample
│   ├── package_tes.png         # Package test example
│   ├── packages.png            # Packages code sample
│   ├── procedures.png          # Procedures code sample
│   ├── sequences.png           # Sequences code sample
│   ├── tables.png              # Tables code sample
│   ├── triggers.png            # Triggers code sample
│   ├── window_function1.png    # Window function example 1
│   └── window_function2.png    # Window function example 2
├── Phase_II_BPMN_Model.md
├── Phase_III_Logical_Model.md
└── README.md
```

---

## Oracle Database Express Home

![Oracle Database Express Home](/images/Monitor.png)

---

## Phase I – Project Description & Problem Statement
![PDF for phase one](/FINAL%20PRACTICUM%20PROJECT[1].pdf)
```sql
-- Phase I: No code, see PDF for requirements and objectives.
```
**Objective:** Outline the core problem of manual internship/job matching in university career services.

### Key Points
- **Problem Definition:** Lack of structure leads to missed opportunities for students and low placement efficiency.
- **Context:** Stakeholders include students, career services, employers, and university leadership.
- **Goals:** Automate matching, improve placement rates, and provide data‑driven insights.

Please see `Phase_I_Problem_Statement.md` for full narrative and objectives.

---

## Phase II – Business Process Model (BPMN)
![Business Process Model](/images/bpm_diagram.svg)
```sql
-- BPMN diagrams are for process modeling, not code.
-- See Phase_II_BPMN_Model.md for process details.
```
**Description:**
- Swimlanes for Student, MIS System, Career Services, and Employer.
- Key tasks, decision gateways, and message flows map end‑to‑end application, review, and offer processes.
- Enables automation of matching and real‑time status notifications.

Full details and diagram annotations in `Phase_II_BPMN_Model.md`.

---

## Phase III – Logical Model Design

**Pluggable Database**

![PDB](/Phase4/PDB%20Creation.png)

By creating pluggable databse it allows as to create and modify the all tables and other things that requires to have PDB like sql developer connections.


![Logical ER Model](/Phase3/logical_model.png)
```sql
-- Example: Table creation based on logical model
CREATE TABLE STUDENT (
  student_id NUMBER PRIMARY KEY,
  name VARCHAR2(100),
  email VARCHAR2(100) UNIQUE
);

CREATE TABLE EMPLOYER (
  employer_id NUMBER PRIMARY KEY,
  company_name VARCHAR2(100)
);

-- ...other tables as per logical model...
```
**Description:**
- Detailed ER diagram showing STUDENT, EMPLOYER, JOB_POSTING, APPLICATION, INTERVIEW, and OFFER.
- Attributes, PKs, FKs, and constraints defined to enforce business rules and maintain 3NF.
- Supports scalable data scenarios like multiple interview rounds and single-offer enforcement.

See `Phase_III_Logical_Model.md` for entity definitions, relationship cardinalities, and normalization justification.

---

## PL/SQL Implementation Snapshots

- **Tables:**  
  ![Tables](/images/table%20creation.png)
  ```sql
  CREATE TABLE JOB_POSTING (
    job_id NUMBER PRIMARY KEY,
    employer_id NUMBER REFERENCES EMPLOYER(employer_id),
    title VARCHAR2(100),
    description VARCHAR2(500)
  );
  ```



- **Procedures:**  
  ![Procedures](/images/Standarone%20procedure.png)
  ```sql
  CREATE OR REPLACE PROCEDURE add_student(
    p_name VARCHAR2,
    p_email VARCHAR2
  ) AS
  BEGIN
    INSERT INTO STUDENT (student_id, name, email)
    VALUES (student_seq.NEXTVAL, p_name, p_email);
  END;
  /
  ```

- **Functions:**  
  ![Functions](/images/function.png)
  ```sql
  CREATE OR REPLACE FUNCTION get_student_email(
    p_student_id NUMBER
  ) RETURN VARCHAR2 IS
    v_email VARCHAR2(100);
  BEGIN
    SELECT email INTO v_email FROM STUDENT WHERE student_id = p_student_id;
    RETURN v_email;
  END;
  /
  ```

- **Packages:**  
  ![Packages](/images/Packages%20placement.png)
  ```sql
  CREATE OR REPLACE PACKAGE student_pkg AS
    PROCEDURE add_student(p_name VARCHAR2, p_email VARCHAR2);
    FUNCTION get_student_email(p_student_id NUMBER) RETURN VARCHAR2;
  END student_pkg;
  /
  ```

- **Package Test Example:**  
  ![Package Test](/images/Testing.png)
  ```sql
  BEGIN
    student_pkg.add_student('Jane Doe', 'jane@example.com');
    DBMS_OUTPUT.PUT_LINE(student_pkg.get_student_email(1));
  END;
  /
  ```

- **Triggers:**  
  ![Triggers](/images/Triggewrs.png)
  ```sql
  CREATE OR REPLACE TRIGGER trg_before_insert_student
  BEFORE INSERT ON STUDENT
  FOR EACH ROW
  BEGIN
    :NEW.email := LOWER(:NEW.email);
  END;
  /
  ```

- **Window Function Example 1:**  
  ![Window Function 1](/images/window%20functions.png)
  ```sql
  SELECT student_id, 
         name, 
         RANK() OVER (ORDER BY GPA DESC) AS gpa_rank
  FROM STUDENT;
  ```

- **Window Function Example 2:**  
  ![Window Function 2](/images/window_function1.png)
  ```sql
  SELECT job_id, 
         title, 
         COUNT(*) OVER (PARTITION BY employer_id) AS jobs_per_employer
  FROM JOB_POSTING;
  ```

---

## How to Use This Repo
1. Clone (private) to your local machine.
2. Review each markdown file for narrative, diagrams, and model details.
3. Open images in the `images` folder to view diagrams and code snapshots.
4. Share with stakeholders or use as documentation in your MIS implementation.

---

*All diagrams were created in draw.io and exported as PNG.*

