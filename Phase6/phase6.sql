-- ############################################################
-- 1) TWO WINDOW‐FUNCTION QUERIES
-- ############################################################

-- 1.1 Top 3 candidates by match_score for each job_posting
SELECT posting_id,
       application_id,
       student_id,
       match_score,
       ROW_NUMBER() OVER (
         PARTITION BY posting_id
         ORDER BY match_score DESC
       ) AS rn
FROM applications
WHERE ROWNUM <= 100
ORDER BY posting_id, 
rn;

-- 1.2 Cumulative average match_score per student over their application history
SELECT student_id,
       apply_date,
       match_score,
       ROUND(
         AVG(match_score) OVER (
           PARTITION BY student_id
           ORDER BY apply_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
         ), 2
       ) AS cum_avg_score
FROM applications
ORDER BY student_id, apply_date;

-- ############################################################
-- 2) TWO STANDALONE PROCEDURES
-- ############################################################

-- 2.1 Update an application's status
CREATE OR REPLACE PROCEDURE proc_update_application_status (
  p_app_id   IN applications.application_id%TYPE,
  p_status   IN applications.status%TYPE
) AS
BEGIN
  UPDATE applications
     SET status = p_status
   WHERE application_id = p_app_id;
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'No such application: ' || p_app_id);
  END IF;
  COMMIT;
END proc_update_application_status;
/

-- 2.2 Schedule a new interview
CREATE OR REPLACE PROCEDURE proc_schedule_interview (
  p_app_id        IN applications.application_id%TYPE,
  p_sched_time    IN interviews.scheduled_time%TYPE,
  p_location      IN interviews.location%TYPE
) AS
  v_new_id  NUMBER;
BEGIN
  SELECT interviews_seq.NEXTVAL INTO v_new_id FROM dual;  -- assume you’ve created a seq
  INSERT INTO interviews(interview_id, application_id, scheduled_time, location, result)
  VALUES (v_new_id, p_app_id, p_sched_time, p_location, 'pending');
  COMMIT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Cannot generate interview id.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END proc_schedule_interview;
/

-- ############################################################
-- 3) TWO STANDALONE FUNCTIONS
-- ############################################################

-- 3.1 Return a student’s full name
CREATE OR REPLACE FUNCTION func_get_fullname (
  p_student_id  IN students.student_id%TYPE
) RETURN VARCHAR2 IS
  v_fname  students.first_name%TYPE;
  v_lname  students.last_name%TYPE;
BEGIN
  SELECT first_name, last_name
    INTO v_fname, v_lname
    FROM students
   WHERE student_id = p_student_id;
  RETURN v_fname || ' ' || v_lname;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN '<<Unknown Student #' || p_student_id || '>>';
END func_get_fullname;
/

-- 3.2 Compute days between apply_date and (first) offer_date
CREATE OR REPLACE FUNCTION func_days_to_offer (
  p_app_id  IN applications.application_id%TYPE
) RETURN NUMBER IS
  v_apply  applications.apply_date%TYPE;
  v_offer  offers.offer_date%TYPE;
BEGIN
  SELECT a.apply_date, o.offer_date
    INTO v_apply, v_offer
    FROM applications a
    JOIN offers      o ON o.application_id = a.application_id
   WHERE a.application_id = p_app_id;
  RETURN v_offer - v_apply;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END func_days_to_offer;
/

-- ############################################################
-- 4) CURSOR DEMONSTRATION
-- ############################################################

DECLARE
  CURSOR c_pending_apps IS
    SELECT application_id, student_id, posting_id
      FROM applications
     WHERE status = 'pending';
  v_app   c_pending_apps%ROWTYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Pending applications:');
  OPEN c_pending_apps;
  LOOP
    FETCH c_pending_apps INTO v_app;
    EXIT WHEN c_pending_apps%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'App '||v_app.application_id
      ||', Student '||v_app.student_id
      ||', Posting '||v_app.posting_id
    );
  END LOOP;
  CLOSE c_pending_apps;
END;
/

-- ############################################################
-- 5) PL/SQL PACKAGE: PLACEMENT_PKG
-- ############################################################

CREATE OR REPLACE PACKAGE placement_pkg AS
  -- Returns top N candidates for a posting
  TYPE t_app_tab IS TABLE OF applications.application_id%TYPE;
  FUNCTION get_top_candidates (
    p_posting_id IN job_postings.posting_id%TYPE,
    p_limit      IN PLS_INTEGER
  ) RETURN t_app_tab PIPELINED;

  -- Returns total applications for a given status
  FUNCTION count_apps_by_status (
    p_status IN applications.status%TYPE
  ) RETURN PLS_INTEGER;

  -- Reject all pending apps older than N days
  PROCEDURE purge_old_pending (
    p_days_old IN PLS_INTEGER
  );
END placement_pkg;
/
CREATE OR REPLACE PACKAGE BODY placement_pkg AS

  FUNCTION get_top_candidates (
    p_posting_id IN job_postings.posting_id%TYPE,
    p_limit      IN PLS_INTEGER
  ) RETURN t_app_tab PIPELINED IS
  BEGIN
    FOR rec IN (
      SELECT application_id
        FROM (
          SELECT application_id,
                 ROW_NUMBER() OVER (
                   PARTITION BY posting_id
                   ORDER BY match_score DESC
                 ) AS rn
            FROM applications
           WHERE posting_id = p_posting_id
        )
       WHERE rn <= p_limit
    )
    LOOP
      PIPE ROW(rec.application_id);
    END LOOP;
    RETURN;
  END get_top_candidates;

  FUNCTION count_apps_by_status (
    p_status IN applications.status%TYPE
  ) RETURN PLS_INTEGER IS
    v_count  PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_count
      FROM applications
     WHERE status = p_status;
    RETURN v_count;
  END count_apps_by_status;

  PROCEDURE purge_old_pending (
    p_days_old IN PLS_INTEGER
  ) IS
  BEGIN
    DELETE FROM applications
     WHERE status = 'pending'
       AND apply_date < TRUNC(SYSDATE) - p_days_old;
    COMMIT;
  END purge_old_pending;

END placement_pkg;
/

-- ############################################################
-- 6) TESTING ALL OBJECTS
-- ############################################################

-- 6.1 Test Procedures
BEGIN
  proc_update_application_status(1000, 'accepted');
  DBMS_OUTPUT.PUT_LINE('Status updated for app 1000.');
END;
/
BEGIN
  proc_schedule_interview(1004, SYSTIMESTAMP + INTERVAL '2' DAY, 'Virtual Room A');
  DBMS_OUTPUT.PUT_LINE('Interview scheduled for app 1004.');
END;
/

-- 6.2 Test Functions
DECLARE
  v_name  VARCHAR2(100);
  v_days  NUMBER;
BEGIN
  v_name := func_get_fullname(3);
  DBMS_OUTPUT.PUT_LINE('Student #3 = ' || v_name);

  v_days := func_days_to_offer(1003);
  DBMS_OUTPUT.PUT_LINE('Days to offer for app 1003 = ' || v_days);
END;
/

-- 6.3 Test Package
--  6.3.1 Top 2 candidates for posting 100
SELECT * FROM TABLE(placement_pkg.get_top_candidates(100,2));

--  6.3.2 Count all ‘accepted’ applications
DECLARE
  v_cnt  PLS_INTEGER;
BEGIN
  v_cnt := placement_pkg.count_apps_by_status('accepted');
  DBMS_OUTPUT.PUT_LINE('Accepted apps = ' || v_cnt);
END;
/

--  6.3.3 Purge pending apps older than 30 days
BEGIN
  placement_pkg.purge_old_pending(30);
  DBMS_OUTPUT.PUT_LINE('Old pending applications purged.');
END;
/
