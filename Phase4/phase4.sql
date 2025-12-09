-- 1) Connect as a privileged user (you’ll need OS or password authentication):
CONNECT / AS SYSDBA;
alter session set container=CDB$ROOT; 
-------------------------------------------------------------------
-- 2) Create the new PDB
-------------------------------------------------------------------
CREATE PLUGGABLE DATABASE Tue_27818_Nelly_Internship_and_job_placement_DB
  ADMIN USER pdb_admin IDENTIFIED BY nelly
  ROLES = (DBA)
  FILE_NAME_CONVERT = (
    'C:\app\HP\product\21c\oradata\XE\pdbseed', 
    'C:\app\HP\product\21c\oradata\XE\Tue_27818_Nelly_Internship_and_job_placement_DB/'
  );
/
-- Explanation:
--  • Tue_27818_Nelly_Internship_and_job_placement_DB
--      is your PDB name (GrpName_StudentId_FirstName_ProjectName_DB).
--  • ADMIN USER pdb_admin IDENTIFIED BY nelly
--      creates a local admin inside the PDB whose password is “nelly.”
--  • ROLES=(DBA)
--      gives that admin the full DBA role in this PDB.
--  • FILE_NAME_CONVERT
--      tells Oracle where to copy the seed files; adjust paths to
--      match wherever your ORACLE_BASE/ORACLE_HOME stores datafiles.

-------------------------------------------------------------------
-- 3) Open the new PDB so it’s available for use
-------------------------------------------------------------------
ALTER PLUGGABLE DATABASE Tue_27818_Nelly_Internship_and_job_placement_DB OPEN;
/

-------------------------------------------------------------------
-- 4) (Optional) Make it open automatically at CDB startup
-------------------------------------------------------------------
ALTER PLUGGABLE DATABASE Tue_27818_Nelly_Internship_and_job_placement_DB SAVE STATE;
/

alter session set container= Tue_27818_Nelly_Internship_and_job_placement_DB;

-------------------------------------------------------------------
-- 5) Connect to your new PDB as the admin user
-------------------------------------------------------------------
CONNECT pdb_admin/nelly@Tue_27818_Nelly_Internship_and_job_placement_DB

-- Verify you’re in the right container:
SHOW CON_NAME;    -- should print “Tue_27818_Nelly_Internship_and_job_placement_DB”
SHOW USER;        -- should print “PDB_ADMIN”
