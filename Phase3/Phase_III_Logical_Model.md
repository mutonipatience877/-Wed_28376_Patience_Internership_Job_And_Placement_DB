# Phase III – Logical Data Model

![Logical_Model_Diagram](/Phase3/logical_model.png)

**Objective:**  
Define a 3NF logical ER model that captures all entities, attributes, keys, and constraints needed to support the BPMN process.

---

## Entities & Attributes

- **STUDENT** (`student_id`, first_name, last_name, email, password_hash, profile_completed, created_at)  
- **EMPLOYER** (`employer_id`, company_name, contact_name, contact_email, phone, created_at)  
- **JOB_POSTING** (`posting_id`, employer_id → EMPLOYER, title, description, requirements, posted_date, application_deadline)  
- **APPLICATION** (`application_id`, student_id → STUDENT, posting_id → JOB_POSTING, apply_date, status, match_score)  
- **INTERVIEW** (`interview_id`, application_id → APPLICATION, scheduled_time, location, result)  
- **OFFER** (`offer_id`, application_id → APPLICATION, offer_date, salary, status)

---

## Relationships & Constraints

- **One‑to‑Many:**  
  - STUDENT → APPLICATION  
  - EMPLOYER → JOB_POSTING  
  - JOB_POSTING → APPLICATION  
  - APPLICATION → INTERVIEW  
- **One‑to‑One:**  
  - APPLICATION → OFFER (enforced via UNIQUE FK)  
- **Data Integrity:**  
  - UNIQUE emails, NOT NULL on required fields  
  - CHECK on `apply_date ≤ application_deadline`  
  - ENUMs for status fields to restrict values  

---

*This logical model ensures no redundancy, enforces business rules, and fully normalizes data to 3NF.*  


[logicalModelDiagram]: Phase3/logical_Model.png