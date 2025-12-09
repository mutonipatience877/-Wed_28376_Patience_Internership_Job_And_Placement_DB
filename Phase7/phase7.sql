-- HOLIDAY DATES TABLE
CREATE TABLE holiday_dates (
  holiday_date DATE PRIMARY KEY,
  description   VARCHAR2(100)
);

-- Populate with 3 sample holidays for the next month
INSERT INTO holiday_dates VALUES (TO_DATE('2025-06-01','YYYY-MM-DD'), 'National Youth Day');
INSERT INTO holiday_dates VALUES (TO_DATE('2025-06-12','YYYY-MM-DD'), 'Founders Day');
INSERT INTO holiday_dates VALUES (TO_DATE('2025-06-25','YYYY-MM-DD'), 'Unity Holiday');
COMMIT;

-- AUDIT TABLE
CREATE TABLE audit_log (
  audit_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  username     VARCHAR2(100),
  action_time  TIMESTAMP DEFAULT SYSTIMESTAMP,
  table_name   VARCHAR2(50),
  operation    VARCHAR2(10),
  status       VARCHAR2(10), -- 'allowed' or 'denied'
  reason       VARCHAR2(200)
);




CREATE OR REPLACE PACKAGE security_pkg AS
  FUNCTION is_restricted RETURN BOOLEAN;
  PROCEDURE log_audit(p_table VARCHAR2, p_op VARCHAR2, p_status VARCHAR2, p_reason VARCHAR2);
END security_pkg;
/

CREATE OR REPLACE PACKAGE BODY security_pkg AS

  FUNCTION is_restricted RETURN BOOLEAN IS
    v_today   DATE := TRUNC(SYSDATE);
    v_dow     VARCHAR2(10);
    v_count   NUMBER;
  BEGIN
    SELECT TO_CHAR(v_today, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH')
    INTO v_dow FROM dual;
    
    IF v_dow IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM holiday_dates
    WHERE holiday_date = v_today;

    IF v_count > 0 THEN
      RETURN TRUE;
    END IF;

    RETURN FALSE;
  END;

  PROCEDURE log_audit(p_table VARCHAR2, p_op VARCHAR2, p_status VARCHAR2, p_reason VARCHAR2) IS
  BEGIN
    INSERT INTO audit_log(username, table_name, operation, status, reason)
    VALUES (USER, p_table, p_op, p_status, p_reason);
  END;

END security_pkg;
/


CREATE OR REPLACE TRIGGER trg_secure_postings
BEFORE INSERT OR UPDATE OR DELETE ON job_postings
FOR EACH ROW
DECLARE
  v_op VARCHAR2(10);
BEGIN
  IF INSERTING THEN v_op := 'INSERT';
  ELSIF UPDATING THEN v_op := 'UPDATE';
  ELSIF DELETING THEN v_op := 'DELETE';
  END IF;

  IF security_pkg.is_restricted THEN
    security_pkg.log_audit('JOB_POSTINGS', v_op, 'denied', 'Restricted day');
    RAISE_APPLICATION_ERROR(-20010, 'Operation blocked during restricted period.');
  ELSE
    security_pkg.log_audit('JOB_POSTINGS', v_op, 'allowed', 'Operation permitted');
  END IF;
END;
/




CREATE OR REPLACE TRIGGER trg_app_audit
FOR INSERT OR DELETE OR UPDATE ON applications
COMPOUND TRIGGER
  TYPE t_op IS RECORD (app_id NUMBER, op VARCHAR2(10));
  TYPE t_tab IS TABLE OF t_op INDEX BY BINARY_INTEGER;
  g_logs t_tab;
  i      INTEGER := 0;

  BEFORE EACH ROW IS
  BEGIN
    i := i + 1;
    IF INSERTING THEN
      g_logs(i).app_id := :NEW.application_id;
      g_logs(i).op := 'INSERT';
    ELSIF UPDATING THEN
      g_logs(i).app_id := :NEW.application_id;
      g_logs(i).op := 'UPDATE';
    ELSIF DELETING THEN
      g_logs(i).app_id := :OLD.application_id;
      g_logs(i).op := 'DELETE';
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    FOR j IN 1..i LOOP
      IF security_pkg.is_restricted THEN
        security_pkg.log_audit('APPLICATIONS', g_logs(j).op, 'denied', 'Operation on restricted date');
        RAISE_APPLICATION_ERROR(-20020, 'Blocked operation during restricted date.');
      ELSE
        security_pkg.log_audit('APPLICATIONS', g_logs(j).op, 'allowed', 'Operation permitted');
      END IF;
    END LOOP;
  END AFTER STATEMENT;

END trg_app_audit;
/

-- Try inserting a job posting (should be denied if today is restricted)
BEGIN
  INSERT INTO job_postings(posting_id, employer_id, title, description, requirements, posted_date, application_deadline)
  VALUES (108, 10, 'Backend Intern', 'Backend microservices', 'Spring Boot', SYSDATE, SYSDATE + 30);
END;
/

-- View the audit log
SELECT * FROM audit_log ORDER BY action_time DESC;
