-- 1) STUDENTS
CREATE TABLE students (
  student_id       NUMBER(10)       PRIMARY KEY,
  first_name       VARCHAR2(50)     NOT NULL,
  last_name        VARCHAR2(50)     NOT NULL,
  email            VARCHAR2(100)    NOT NULL UNIQUE,
  password_hash    VARCHAR2(256)    NOT NULL,
  profile_completed CHAR(1)         DEFAULT 'N' CHECK (profile_completed IN ('Y','N')),
  created_at       TIMESTAMP        DEFAULT SYSTIMESTAMP NOT NULL
);

-- 2) EMPLOYERS
CREATE TABLE employers (
  employer_id      NUMBER(10)       PRIMARY KEY,
  company_name     VARCHAR2(100)    NOT NULL,
  contact_name     VARCHAR2(100)    NOT NULL,
  contact_email    VARCHAR2(100)    NOT NULL UNIQUE,
  phone            VARCHAR2(20),
  created_at       TIMESTAMP        DEFAULT SYSTIMESTAMP NOT NULL
);

-- 3) JOB_POSTINGS
CREATE TABLE job_postings (
  posting_id          NUMBER(10)     PRIMARY KEY,
  employer_id         NUMBER(10)     NOT NULL,
  title               VARCHAR2(150)  NOT NULL,
  description         VARCHAR2(4000),
  requirements        VARCHAR2(2000),
  posted_date         DATE           NOT NULL,
  application_deadline DATE          NOT NULL,
  CONSTRAINT fk_posting_employer
    FOREIGN KEY(employer_id) REFERENCES employers(employer_id)
);

-- 4) APPLICATIONS

CREATE TABLE applications (
  application_id   NUMBER(10)       PRIMARY KEY,
  student_id       NUMBER(10)       NOT NULL,
  posting_id       NUMBER(10)       NOT NULL,
  apply_date       DATE             NOT NULL,
  status           VARCHAR2(20)     DEFAULT 'pending' 
                      CHECK (status IN ('pending','rejected','accepted')),
  match_score      NUMBER(5,2)      CHECK (match_score BETWEEN 0 AND 100),
  CONSTRAINT fk_app_student
    FOREIGN KEY(student_id)  REFERENCES students(student_id),
  CONSTRAINT fk_app_posting
    FOREIGN KEY(posting_id)  REFERENCES job_postings(posting_id)
);

-- 5) INTERVIEWS
CREATE TABLE interviews (
  interview_id     NUMBER(10)       PRIMARY KEY,
  application_id   NUMBER(10)       NOT NULL,
  scheduled_time   TIMESTAMP        NOT NULL,
  location         VARCHAR2(200),
  result           VARCHAR2(20)     DEFAULT 'pending' CHECK (result IN ('pending','pass','fail','no-show')),
  CONSTRAINT fk_int_app
    FOREIGN KEY(application_id) REFERENCES applications(application_id)
);

-- 6) OFFERS
CREATE TABLE offers (
  offer_id         NUMBER(10)       PRIMARY KEY,
  application_id   NUMBER(10)       NOT NULL UNIQUE,
  offer_date       DATE             NOT NULL,
  salary           NUMBER(10,2)     NOT NULL,
  status           VARCHAR2(20)     DEFAULT 'extended' CHECK (status IN ('extended','accepted','declined')),
  CONSTRAINT fk_off_app
    FOREIGN KEY(application_id) REFERENCES applications(application_id)
);

-------------------------------------------------------------------------------
-- 2) INSERT SAMPLE DATA: at least 8 rows per table
-------------------------------------------------------------------------------

-- STUDENTS
INSERT INTO students VALUES (1,'Alice','Wong','alice.wong@example.com','hash1','Y',TIMESTAMP '2025-01-10 08:15:00');
INSERT INTO students VALUES (2,'Bob','Smith','bob.smith@example.com','hash2','N',TIMESTAMP '2025-02-12 10:30:00');
INSERT INTO students VALUES (3,'Carla','Jones','carla.jones@example.com','hash3','Y',TIMESTAMP '2025-03-05 14:45:00');
INSERT INTO students VALUES (4,'David','Lee','david.lee@example.com','hash4','Y',TIMESTAMP '2025-01-20 09:00:00');
INSERT INTO students VALUES (5,'Eva','Martinez','eva.martinez@example.com','hash5','N',TIMESTAMP '2025-02-25 16:20:00');
INSERT INTO students VALUES (6,'Frank','Taylor','frank.taylor@example.com','hash6','Y',TIMESTAMP '2025-03-15 11:10:00');
INSERT INTO students VALUES (7,'Grace','Chen','grace.chen@example.com','hash7','Y',TIMESTAMP '2025-01-30 13:55:00');
INSERT INTO students VALUES (8,'Henry','Gupta','henry.gupta@example.com','hash8','N',TIMESTAMP '2025-02-07 12:00:00');

-- EMPLOYERS
INSERT INTO employers VALUES (10,'Acme Corp','John Doe','j.doe@acme.com','555-1001',TIMESTAMP '2024-12-01 09:00:00');
INSERT INTO employers VALUES (11,'Beta LLC','Susan Ray','s.ray@beta.com','555-1002',TIMESTAMP '2024-12-05 10:15:00');
INSERT INTO employers VALUES (12,'Gamma Inc','Paul Kim','p.kim@gamma.com','555-1003',TIMESTAMP '2024-12-10 11:30:00');
INSERT INTO employers VALUES (13,'Delta Solutions','Linda Cruz','l.cruz@delta.com','555-1004',TIMESTAMP '2024-12-15 14:00:00');
INSERT INTO employers VALUES (14,'Epsilon Ltd','Mike White','m.white@epsilon.com','555-1005',TIMESTAMP '2024-12-20 15:45:00');
INSERT INTO employers VALUES (15,'Zeta Enterprises','Nina Patel','n.patel@zeta.com','555-1006',TIMESTAMP '2024-12-22 16:20:00');
INSERT INTO employers VALUES (16,'Eta Systems','Oliver Stone','o.stone@eta.com','555-1007',TIMESTAMP '2024-12-25 08:30:00');
INSERT INTO employers VALUES (17,'Theta Partners','Paula Reed','p.reed@theta.com','555-1008',TIMESTAMP '2024-12-28 09:50:00');

-- JOB_POSTINGS
INSERT INTO job_postings VALUES (100,10,'Software Intern','Work on web apps','SQL, Java, team player',DATE '2025-02-01',DATE '2025-03-01');
INSERT INTO job_postings VALUES (101,11,'Marketing Intern','Social media campaigns','Creative, writing skills',DATE '2025-02-10',DATE '2025-03-10');
INSERT INTO job_postings VALUES (102,12,'Data Analyst','Analyze datasets','SQL, Excel, Python',DATE '2025-01-20',DATE '2025-02-20');
INSERT INTO job_postings VALUES (103,13,'HR Assistant','Support recruitment','Communication, MS Office',DATE '2025-02-05',DATE '2025-03-05');
INSERT INTO job_postings VALUES (104,14,'Finance Intern','Assist accounting','Excel, attention to detail',DATE '2025-02-15',DATE '2025-03-15');
INSERT INTO job_postings VALUES (105,15,'UX Designer Intern','Design interfaces','Figma, creativity',DATE '2025-01-30',DATE '2025-02-28');
INSERT INTO job_postings VALUES (106,16,'Network Engineer Intern','Manage networks','Cisco, troubleshooting',DATE '2025-01-25',DATE '2025-02-25');
INSERT INTO job_postings VALUES (107,17,'Content Writer','Write blog posts','Writing, research',DATE '2025-02-12',DATE '2025-03-12');

-- APPLICATIONS
INSERT INTO applications VALUES (1000,1,100,DATE '2025-02-02','pending', 82.50);
INSERT INTO applications VALUES (1001,2,101,DATE '2025-02-11','pending', 75.00);
INSERT INTO applications VALUES (1002,3,102,DATE '2025-01-21','rejected', 60.20);
INSERT INTO applications VALUES (1003,4,103,DATE '2025-02-06','accepted', 88.10);
INSERT INTO applications VALUES (1004,5,104,DATE '2025-02-16','pending', 70.00);
INSERT INTO applications VALUES (1005,6,105,DATE '2025-01-31','pending', 91.30);
INSERT INTO applications VALUES (1006,7,106,DATE '2025-01-26','rejected', 55.75);
INSERT INTO applications VALUES (1007,8,107,DATE '2025-02-13','accepted', 80.00);

-- INTERVIEWS
INSERT INTO interviews VALUES (2000,1000,TIMESTAMP '2025-02-05 10:00:00','Acme HQ','pass');
INSERT INTO interviews VALUES (2001,1001,TIMESTAMP '2025-02-14 11:30:00','Beta Office','pending');
INSERT INTO interviews VALUES (2002,1002,TIMESTAMP '2025-01-23 09:00:00','Gamma Site','fail');
INSERT INTO interviews VALUES (2003,1003,TIMESTAMP '2025-02-08 14:00:00','Delta Center','pass');
INSERT INTO interviews VALUES (2004,1004,TIMESTAMP '2025-02-18 13:15:00','Epsilon Plaza','pending');
INSERT INTO interviews VALUES (2005,1005,TIMESTAMP '2025-02-02 15:45:00','Zeta Tower','no-show');
INSERT INTO interviews VALUES (2006,1006,TIMESTAMP '2025-01-28 10:30:00','Eta Building','fail');
INSERT INTO interviews VALUES (2007,1007,TIMESTAMP '2025-02-16 12:00:00','Theta Suite','pass');

-- OFFERS
INSERT INTO offers VALUES (3000,1000,DATE '2025-02-10',55000.00,'extended');
INSERT INTO offers VALUES (3001,1003,DATE '2025-02-12',48000.00,'accepted');
INSERT INTO offers VALUES (3002,1007,DATE '2025-02-18',42000.00,'extended');
INSERT INTO offers VALUES (3003,1001,DATE '2025-02-20',39000.00,'declined');
INSERT INTO offers VALUES (3004,1004,DATE '2025-02-25',45000.00,'extended');
INSERT INTO offers VALUES (3005,1005,DATE '2025-02-05',50000.00,'declined');
INSERT INTO offers VALUES (3006,1002,DATE '2025-01-25',40000.00,'extended');
INSERT INTO offers VALUES (3007,1006,DATE '2025-01-30',36000.00,'extended');
