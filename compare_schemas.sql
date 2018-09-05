REM
REM compare_schemas.sql
REM ===================
REM
REM This script is provided by Database Specialists, Inc. 
REM (http://www.dbspecialists.com) for individual use and not for sale. 
REM Database Specialists, Inc. does not warrant the script in any way 
REM and will not be responsible for any loss arising out of its use.
REM
REM Your feedback is welcome! Please send your comments about this script
REM to scriptfeedback@dbspecialists.com
REM
REM This script will compare two Oracle schemas and generate a report of
REM discrepancies. This script has been used against Oracle 7.3.4, 8.0.5,
REM and 8.1.7 databases, but it should also work with other versions. 
REM
REM Please note that the following schema object types and attributes are 
REM not compared by this script at this time:
REM
REM         cluster definitions
REM         comments on tables and columns
REM         nesting, partition, IOT, and temporary attributes of tables
REM         snapshots/materialized views, logs, and refresh groups
REM         foreign function libraries
REM         object types
REM         operators
REM         indextypes
REM         dimensions
REM         auditing information
REM         new schema attributes added for Oracle 9i
REM
REM Version 02-04-2002
REM

PROMPT
PROMPT Schema Comparison
PROMPT =================
PROMPT
PROMPT Run this script while connected to one Oracle schema. Enter the Oracle
PROMPT username, password, and SQL*Net / Net8 service name of a second schema.
PROMPT This script will compare the two schemas and generate a report of
PROMPT differences.
PROMPT
PROMPT A temporary database link and table will be created and dropped by 
PROMPT this script.
PROMPT

ACCEPT schema CHAR PROMPT "Enter username for remote schema: "
ACCEPT passwd CHAR PROMPT "Enter password for remote schema: " HIDE
ACCEPT tnssvc CHAR PROMPT "Enter SQL*Net / Net8 service for remote schema: "

PROMPT

ACCEPT report CHAR PROMPT "Enter filename for report output: "

SET FEEDBACK OFF
SET VERIFY   OFF

CREATE DATABASE LINK rem_schema CONNECT TO &schema IDENTIFIED BY &passwd
USING '&tnssvc';

SET TRIMSPOOL ON

SPOOL &report

SELECT SUBSTR (RPAD (TO_CHAR (SYSDATE, 'mm/dd/yyyy hh24:mi:ss'), 25), 1, 25) 
       "REPORT DATE AND TIME"
FROM   SYS.dual;

COL local_schema  FORMAT a35 TRUNC HEADING "LOCAL SCHEMA"
COL remote_schema FORMAT a35 TRUNC HEADING "REMOTE SCHEMA"

SELECT USER || '@' || C.global_name local_schema,
       A.username || '@' || B.global_name remote_schema
FROM   user_users@rem_schema A, global_name@rem_schema B, global_name C
WHERE  ROWNUM = 1;

SET PAGESIZE  9999
SET LINESIZE  250
SET FEEDBACK  1

SET TERMOUT OFF

PROMPT

REM Object differences
REM ==================

COL object_name FORMAT a30

PROMPT SUMMARY OF OBJECTS MISSING FROM LOCAL SCHEMA

SELECT   object_type, COUNT (*)
FROM
(
SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name)
FROM     user_objects@rem_schema
MINUS
SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name)
FROM     user_objects
)
GROUP BY object_type
ORDER BY object_type;

PROMPT SUMMARY OF EXTRANEOUS OBJECTS IN LOCAL SCHEMA

SELECT   object_type, COUNT (*)
FROM
(
SELECT   object_type, 
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name)
FROM     user_objects
WHERE    object_type != 'DATABASE LINK'
OR       object_name NOT LIKE 'REM_SCHEMA.%'
MINUS
SELECT   object_type, 
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name)
FROM     user_objects@rem_schema
)
GROUP BY object_type
ORDER BY object_type;

PROMPT OBJECTS MISSING FROM LOCAL SCHEMA

SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name) object_name
FROM     user_objects@rem_schema
MINUS
SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name) object_name
FROM     user_objects
ORDER BY object_type, object_name;

PROMPT EXTRANEOUS OBJECTS IN LOCAL SCHEMA

SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name) object_name
FROM     user_objects
WHERE    object_type != 'DATABASE LINK'
OR       object_name NOT LIKE 'REM_SCHEMA.%'
MINUS
SELECT   object_type,
         DECODE (object_type, 
                 'INDEX', DECODE (SUBSTR (object_name, 1, 5), 
                                  'SYS_C', 'SYS_C', object_name), 
                 'LOB',   DECODE (SUBSTR (object_name, 1, 7),
                                  'SYS_LOB', 'SYS_LOB', object_name),
                 object_name) object_name
FROM     user_objects@rem_schema
ORDER BY object_type, object_name;

PROMPT OBJECTS IN LOCAL SCHEMA THAT ARE NOT VALID

SELECT   object_name, object_type, status
FROM     user_objects
WHERE    status != 'VALID'
ORDER BY object_name, object_type;

REM Table differences
REM =================

PROMPT TABLE COLUMNS MISSING FROM ONE SCHEMA
PROMPT (NOTE THAT THIS REPORT DOES NOT LIST DISCREPANCIES IN COLUMN ORDER)

(
SELECT   table_name, column_name, 'Local' "MISSING IN SCHEMA"
FROM     user_tab_columns@rem_schema
WHERE    table_name IN
         (
         SELECT table_name
         FROM   user_tables
         )
MINUS
SELECT   table_name, column_name, 'Local' "MISSING IN SCHEMA"
FROM     user_tab_columns
)
UNION ALL
(
SELECT   table_name, column_name, 'Remote' "MISSING IN SCHEMA"
FROM     user_tab_columns
WHERE    table_name IN
         (
         SELECT table_name
         FROM   user_tables@rem_schema
         )
MINUS
SELECT   table_name, column_name, 'Remote' "MISSING IN SCHEMA"
FROM     user_tab_columns@rem_schema
)
ORDER BY 1, 2;

COL schema         FORMAT a15
COL nullable       FORMAT a8
COL data_type      FORMAT a9
COL data_length    FORMAT 9999 HEADING LENGTH
COL data_precision FORMAT 9999 HEADING PRECISION
COL data_scale     FORMAT 9999 HEADING SCALE
COL default_length FORMAT 9999 HEADING LENGTH_OF_DEFAULT_VALUE

PROMPT DATATYPE DISCREPANCIES FOR TABLE COLUMNS THAT EXIST IN BOTH SCHEMAS

(
SELECT   table_name, column_name, 'Remote' schema, 
         nullable, data_type, data_length, data_precision, data_scale,
         default_length
FROM     user_tab_columns@rem_schema
WHERE    (table_name, column_name) IN
         (
         SELECT table_name, column_name
         FROM   user_tab_columns
         )
MINUS
SELECT   table_name, column_name, 'Remote' schema, 
         nullable, data_type, data_length, data_precision, data_scale,
         default_length
FROM     user_tab_columns
)
UNION ALL
(
SELECT   table_name, column_name, 'Local' schema,
         nullable, data_type, data_length, data_precision, data_scale,
         default_length
FROM     user_tab_columns
WHERE    (table_name, column_name) IN
         (
         SELECT table_name, column_name
         FROM   user_tab_columns@rem_schema
         )
MINUS
SELECT   table_name, column_name, 'Local' schema,
         nullable, data_type, data_length, data_precision, data_scale,
         default_length
FROM     user_tab_columns@rem_schema
)
ORDER BY 1, 2, 3;

REM Index differences
REM =================

COL column_position FORMAT 999  HEADING ORDER

PROMPT INDEX DISCREPANCIES FOR INDEXES THAT EXIST IN BOTH SCHEMAS

(
SELECT   A.index_name, 'Remote' schema, A.uniqueness, A.table_name, 
         B.column_name, B.column_position
FROM     user_indexes@rem_schema A, user_ind_columns@rem_schema B
WHERE    A.index_name IN
         (
         SELECT index_name
         FROM   user_indexes
         )
AND      B.index_name = A.index_name
AND      B.table_name = A.table_name
MINUS
SELECT   A.index_name, 'Remote' schema, A.uniqueness, A.table_name, 
         B.column_name, B.column_position
FROM     user_indexes A, user_ind_columns B
WHERE    B.index_name = A.index_name
AND      B.table_name = A.table_name
)
UNION ALL
(
SELECT   A.index_name, 'Local' schema, A.uniqueness, A.table_name, 
         B.column_name, B.column_position
FROM     user_indexes A, user_ind_columns B
WHERE    A.index_name IN
         (
         SELECT index_name
         FROM   user_indexes@rem_schema
         )
AND      B.index_name = A.index_name
AND      B.table_name = A.table_name
MINUS
SELECT   A.index_name, 'Local' schema, A.uniqueness, A.table_name, 
         B.column_name, B.column_position
FROM     user_indexes@rem_schema A, user_ind_columns@rem_schema B
WHERE    B.index_name = A.index_name
AND      B.table_name = A.table_name
)
ORDER BY 1, 2, 6;

REM Constraint differences
REM ======================

PROMPT CONSTRAINT DISCREPANCIES FOR TABLES THAT EXIST IN BOTH SCHEMAS

SET FEEDBACK OFF

CREATE TABLE temp_schema_compare
(
database     NUMBER(1),
object_name  VARCHAR2(30),
object_text  VARCHAR2(2000),
hash_value   NUMBER
);

DECLARE
  CURSOR c1 IS
    SELECT constraint_name, search_condition
    FROM   user_constraints
    WHERE  search_condition IS NOT NULL;
  CURSOR c2 IS
    SELECT constraint_name, search_condition
    FROM   user_constraints@rem_schema
    WHERE  search_condition IS NOT NULL;
  v_constraint_name  VARCHAR2(30);
  v_search_condition VARCHAR2(32767);
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO v_constraint_name, v_search_condition;
    EXIT WHEN c1%NOTFOUND;
    v_search_condition := SUBSTR (v_search_condition, 1, 2000);
    INSERT INTO temp_schema_compare
    (
    database, object_name, object_text
    )
    VALUES
    (
    1, v_constraint_name, v_search_condition
    );
  END LOOP;
  CLOSE c1;
  OPEN c2;
  LOOP
    FETCH c2 INTO v_constraint_name, v_search_condition;
    EXIT WHEN c2%NOTFOUND;
    v_search_condition := SUBSTR (v_search_condition, 1, 2000);
    INSERT INTO temp_schema_compare
    (
    database, object_name, object_text
    )
    VALUES
    (
    2, v_constraint_name, v_search_condition
    );
  END LOOP;
  CLOSE c2;
  COMMIT;
END;
/

SET FEEDBACK 1

(
SELECT   REPLACE (TRANSLATE (A.constraint_name,'012345678','999999999'), 
                  '9', NULL) constraint_name,
         'Remote' schema, A.constraint_type, A.table_name,
         A.r_constraint_name, A.delete_rule, A.status, B.object_text
FROM     user_constraints@rem_schema A, temp_schema_compare B
WHERE    A.table_name IN
         (
         SELECT table_name
         FROM   user_tables
         )
AND      B.database (+) = 2
AND      B.object_name (+) = A.constraint_name
MINUS
SELECT   REPLACE (TRANSLATE (A.constraint_name,'012345678','999999999'),
                  '9', NULL) constraint_name,
         'Remote' schema, A.constraint_type, A.table_name,
         A.r_constraint_name, A.delete_rule, A.status, B.object_text
FROM     user_constraints A, temp_schema_compare B
WHERE    B.database (+) = 1
AND      B.object_name (+) = A.constraint_name
)
UNION ALL
(
SELECT   REPLACE (TRANSLATE (A.constraint_name,'012345678','999999999'),
                  '9', NULL) constraint_name,
         'Local' schema, A.constraint_type, A.table_name,
         A.r_constraint_name, A.delete_rule, A.status, B.object_text
FROM     user_constraints A, temp_schema_compare B
WHERE    A.table_name IN
         (
         SELECT table_name
         FROM   user_tables@rem_schema
         )
AND      B.database (+) = 1
AND      B.object_name (+) = A.constraint_name
MINUS
SELECT   REPLACE (TRANSLATE (A.constraint_name,'012345678','999999999'),
                  '9', NULL) constraint_name,
         'Local' schema, A.constraint_type, A.table_name,
         A.r_constraint_name, A.delete_rule, A.status, B.object_text
FROM     user_constraints@rem_schema A, temp_schema_compare B
WHERE    B.database (+) = 2
AND      B.object_name (+) = A.constraint_name
)
ORDER BY 1, 4, 2;

REM Database link differences
REM =========================

PROMPT DATABASE LINK DISCREPANCIES

COL db_link FORMAT a40

(
SELECT   db_link, 'Remote' schema, username, host
FROM     user_db_links@rem_schema
MINUS
SELECT   db_link, 'Remote' schema, username, host
FROM     user_db_links
)
UNION ALL
(
SELECT   db_link, 'Local' schema, username, host
FROM     user_db_links
WHERE    db_link NOT LIKE 'REM_SCHEMA.%'
MINUS
SELECT   db_link, 'Local' schema, username, host
FROM     user_db_links@rem_schema
)
ORDER BY 1, 2;

REM Sequence differences
REM ====================

PROMPT SEQUENCE DISCREPANCIES

(
SELECT   sequence_name, 'Remote' schema, min_value, max_value, 
         increment_by, cycle_flag, order_flag, cache_size
FROM     user_sequences@rem_schema
MINUS
SELECT   sequence_name, 'Remote' schema, min_value, max_value, 
         increment_by, cycle_flag, order_flag, cache_size
FROM     user_sequences
)
UNION ALL
(
SELECT   sequence_name, 'Local' schema, min_value, max_value, 
         increment_by, cycle_flag, order_flag, cache_size
FROM     user_sequences
MINUS
SELECT   sequence_name, 'Local' schema, min_value, max_value, 
         increment_by, cycle_flag, order_flag, cache_size
FROM     user_sequences@rem_schema
)
ORDER BY 1, 2;

REM Private synonym differences
REM ===========================

PROMPT PRIVATE SYNONYM DISCREPANCIES

(
SELECT   synonym_name, 'Remote' schema, table_owner, table_name, db_link
FROM     user_synonyms@rem_schema
MINUS
SELECT   synonym_name, 'Remote' schema, table_owner, table_name, db_link
FROM     user_synonyms
)
UNION ALL
(
SELECT   synonym_name, 'Local' schema, table_owner, table_name, db_link
FROM     user_synonyms
MINUS
SELECT   synonym_name, 'Local' schema, table_owner, table_name, db_link
FROM     user_synonyms@rem_schema
)
ORDER BY 1, 2;

REM PL/SQL differences
REM ==================

PROMPT SOURCE CODE DISCREPANCIES FOR PACKAGES, PROCEDURES, AND FUNCTIONS
PROMPT THAT EXIST IN BOTH SCHEMAS

SELECT   name, type, COUNT (*) discrepancies
FROM
(
(
SELECT   name, type, line, text
FROM     user_source@rem_schema
WHERE    (name, type) IN
         (
         SELECT object_name, object_type
         FROM   user_objects
         )
MINUS
SELECT   name, type, line, text
FROM     user_source
)
UNION ALL
(
SELECT   name, type, line, text
FROM     user_source
WHERE    (name, type) IN
         (
         SELECT object_name, object_type
         FROM   user_objects@rem_schema
         )
MINUS
SELECT   name, type, line, text
FROM     user_source@rem_schema
)
)
GROUP BY name, type
ORDER BY name, type;

PROMPT SOURCE CODE DISCREPANCIES FOR PACKAGES, PROCEDURES, AND FUNCTIONS
PROMPT THAT EXIST IN BOTH SCHEMAS (CASE INSENSITIVE COMPARISON)

SELECT   name, type, COUNT (*) discrepancies
FROM
(
(
SELECT   name, type, line, UPPER (text)
FROM     user_source@rem_schema
WHERE    (name, type) IN
         (
         SELECT object_name, object_type
         FROM   user_objects
         )
MINUS
SELECT   name, type, line, UPPER (text)
FROM     user_source
)
UNION ALL
(
SELECT   name, type, line, UPPER (text)
FROM     user_source
WHERE    (name, type) IN
         (
         SELECT object_name, object_type
         FROM   user_objects@rem_schema
         )
MINUS
SELECT   name, type, line, UPPER (text)
FROM     user_source@rem_schema
)
)
GROUP BY name, type
ORDER BY name, type;

REM Trigger differences
REM ===================

PROMPT TRIGGER DISCREPANCIES

SET FEEDBACK OFF

TRUNCATE TABLE temp_schema_compare;

DECLARE
  CURSOR c1 IS
    SELECT trigger_name, trigger_body
    FROM   user_triggers;
  CURSOR c2 IS
    SELECT trigger_name, trigger_body
    FROM   user_triggers@rem_schema;
  v_trigger_name VARCHAR2(30);
  v_trigger_body VARCHAR2(32767);
  v_hash_value   NUMBER;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO v_trigger_name, v_trigger_body;
    EXIT WHEN c1%NOTFOUND;
    v_trigger_body := REPLACE (v_trigger_body, ' ', NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(9), NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(10), NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(13), NULL);
    v_trigger_body := UPPER (v_trigger_body);
    v_hash_value := dbms_utility.get_hash_value (v_trigger_body, 1, 65536);
    INSERT INTO temp_schema_compare (database, object_name, hash_value)
    VALUES (1, v_trigger_name, v_hash_value);
  END LOOP;
  CLOSE c1;
  OPEN c2;
  LOOP
    FETCH c2 INTO v_trigger_name, v_trigger_body;
    EXIT WHEN c2%NOTFOUND;
    v_trigger_body := REPLACE (v_trigger_body, ' ', NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(9), NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(10), NULL);
    v_trigger_body := REPLACE (v_trigger_body, CHR(13), NULL);
    v_trigger_body := UPPER (v_trigger_body);
    v_hash_value := dbms_utility.get_hash_value (v_trigger_body, 1, 65536);
    INSERT INTO temp_schema_compare (database, object_name, hash_value)
    VALUES (2, v_trigger_name, v_hash_value);
  END LOOP;
  CLOSE c2;
END;
/

SET FEEDBACK 1

(
SELECT   A.trigger_name, 'Local' schema, A.trigger_type,
         A.triggering_event, A.table_name, SUBSTR (A.referencing_names, 1, 30)
         referencing_names, SUBSTR (A.when_clause, 1, 30) when_clause,
         A.status, B.hash_value
FROM     user_triggers A, temp_schema_compare B
WHERE    B.object_name (+) = A.trigger_name
AND      B.database (+) = 1
AND      A.table_name IN
         (
         SELECT table_name
         FROM   user_tables@rem_schema
         )
MINUS
SELECT   A.trigger_name, 'Local' schema, A.trigger_type,
         A.triggering_event, A.table_name, SUBSTR (A.referencing_names, 1, 30)
         referencing_names, SUBSTR (A.when_clause, 1, 30) when_clause,
         A.status, B.hash_value
FROM     user_triggers@rem_schema A, temp_schema_compare B
WHERE    B.object_name (+) = A.trigger_name
AND      B.database (+) = 2
)
UNION ALL
(
SELECT   A.trigger_name, 'Remote' schema, A.trigger_type,
         A.triggering_event, A.table_name, SUBSTR (A.referencing_names, 1, 30)
         referencing_names, SUBSTR (A.when_clause, 1, 30) when_clause,
         A.status, B.hash_value
FROM     user_triggers@rem_schema A, temp_schema_compare B
WHERE    B.object_name (+) = A.trigger_name
AND      B.database (+) = 2
AND      A.table_name IN
         (
         SELECT table_name
         FROM   user_tables
         )
MINUS
SELECT   A.trigger_name, 'Remote' schema, A.trigger_type,
         A.triggering_event, A.table_name, SUBSTR (A.referencing_names, 1, 30)
         referencing_names, SUBSTR (A.when_clause, 1, 30) when_clause,
         A.status, B.hash_value
FROM     user_triggers A, temp_schema_compare B
WHERE    B.object_name (+) = A.trigger_name
AND      B.database (+) = 1
)
ORDER BY 1, 2, 5, 3;

REM View differences
REM ================

PROMPT VIEW DISCREPANCIES

SET FEEDBACK OFF

TRUNCATE TABLE temp_schema_compare;

DECLARE
  CURSOR c1 IS
    SELECT view_name, text
    FROM   user_views;
  CURSOR c2 IS
    SELECT view_name, text
    FROM   user_views@rem_schema;
  v_view_name    VARCHAR2(30);
  v_text         VARCHAR2(32767);
  v_hash_value   NUMBER;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO v_view_name, v_text;
    EXIT WHEN c1%NOTFOUND;
    v_text := REPLACE (v_text, ' ', NULL);
    v_text := REPLACE (v_text, CHR(9), NULL);
    v_text := REPLACE (v_text, CHR(10), NULL);
    v_text := REPLACE (v_text, CHR(13), NULL);
    v_text := UPPER (v_text);
    v_hash_value := dbms_utility.get_hash_value (v_text, 1, 65536);
    INSERT INTO temp_schema_compare (database, object_name, hash_value)
    VALUES (1, v_view_name, v_hash_value);
  END LOOP;
  CLOSE c1;
  OPEN c2;
  LOOP
    FETCH c2 INTO v_view_name, v_text;
    EXIT WHEN c2%NOTFOUND;
    v_text := REPLACE (v_text, ' ', NULL);
    v_text := REPLACE (v_text, CHR(9), NULL);
    v_text := REPLACE (v_text, CHR(10), NULL);
    v_text := REPLACE (v_text, CHR(13), NULL);
    v_text := UPPER (v_text);
    v_hash_value := dbms_utility.get_hash_value (v_text, 1, 65536);
    INSERT INTO temp_schema_compare (database, object_name, hash_value)
    VALUES (2, v_view_name, v_hash_value);
  END LOOP;
  CLOSE c2;
END;
/

SET FEEDBACK 1

(
SELECT   A.view_name, 'Local' schema, B.hash_value
FROM     user_views A, temp_schema_compare B
WHERE    B.object_name (+) = A.view_name
AND      B.database (+) = 1
AND      A.view_name IN
         (
         SELECT view_name
         FROM   user_views@rem_schema
         )
MINUS
SELECT   A.view_name, 'Local' schema, B.hash_value
FROM     user_views@rem_schema A, temp_schema_compare B
WHERE    B.object_name (+) = A.view_name
AND      B.database (+) = 2
)
UNION ALL
(
SELECT   A.view_name, 'Remote' schema, B.hash_value
FROM     user_views@rem_schema A, temp_schema_compare B
WHERE    B.object_name (+) = A.view_name
AND      B.database (+) = 2
AND      A.view_name IN
         (
         SELECT view_name
         FROM   user_views
         )
MINUS
SELECT   A.view_name, 'Remote' schema, B.hash_value
FROM     user_views A, temp_schema_compare B
WHERE    B.object_name (+) = A.view_name
AND      B.database (+) = 1
)
ORDER BY 1, 2;

REM Job queue differences
REM =====================

COL what     FORMAT a30
COL interval FORMAT a30

PROMPT JOB QUEUE DISCREPANCIES

(
SELECT   what, interval, 'Remote' schema
FROM     user_jobs@rem_schema
MINUS
SELECT   what, interval, 'Remote' schema
FROM     user_jobs
)
UNION ALL
(
SELECT   what, interval, 'Local' schema
FROM     user_jobs
MINUS
SELECT   what, interval, 'Local' schema
FROM     user_jobs@rem_schema
)
ORDER BY 1, 2, 3;

REM Privilege differences
REM =====================

PROMPT OBJECT-LEVEL GRANT DISCREPANCIES

(
SELECT   owner, table_name, 'Remote' schema, grantee, privilege, grantable
FROM     user_tab_privs@rem_schema
WHERE    (owner, table_name) IN
         (
         SELECT owner, object_name
         FROM   all_objects
         )
MINUS
SELECT   owner, table_name, 'Remote' schema, grantee, privilege, grantable
FROM     user_tab_privs
)
UNION ALL
(
SELECT   owner, table_name, 'Local' schema, grantee, privilege, grantable
FROM     user_tab_privs
WHERE    (owner, table_name) IN
         (
         SELECT owner, object_name
         FROM   all_objects@rem_schema
         )
MINUS
SELECT   owner, table_name, 'Local' schema, grantee, privilege, grantable
FROM     user_tab_privs@rem_schema
)
ORDER BY 1, 2, 3;

PROMPT SYSTEM PRIVILEGE DISCREPANCIES

(
SELECT   privilege, 'Remote' schema, admin_option
FROM     user_sys_privs@rem_schema
MINUS
SELECT   privilege, 'Remote' schema, admin_option
FROM     user_sys_privs
)
UNION ALL
(
SELECT   privilege, 'Local' schema, admin_option
FROM     user_sys_privs
MINUS
SELECT   privilege, 'Local' schema, admin_option
FROM     user_sys_privs@rem_schema
)
ORDER BY 1, 2;

PROMPT ROLE PRIVILEGE DISCREPANCIES

(
SELECT   granted_role, 'Remote' schema, admin_option, default_role, os_granted
FROM     user_role_privs@rem_schema
MINUS
SELECT   granted_role, 'Remote' schema, admin_option, default_role, os_granted
FROM     user_role_privs
)
UNION ALL
(
SELECT   granted_role, 'Local' schema, admin_option, default_role, os_granted
FROM     user_role_privs
MINUS
SELECT   granted_role, 'Local' schema, admin_option, default_role, os_granted
FROM     user_role_privs@rem_schema
)
ORDER BY 1, 2;

SPOOL OFF

SET TERMOUT ON

PROMPT
PROMPT Report output written to &report

SET FEEDBACK OFF

DROP TABLE temp_schema_compare;
DROP DATABASE LINK rem_schema;

SET FEEDBACK 6
SET PAGESIZE 20
SET LINESIZE 80


