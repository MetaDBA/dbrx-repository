SET SERVEROUTPUT ON SIZE 32767
SET PAGESIZE 99

COL object_name FORMAT a30

SELECT   object_type, object_name
FROM     user_objects
WHERE    status != 'VALID'
ORDER BY object_type, object_name;

DECLARE
  CURSOR c_invalid Is
    SELECT   object_type, object_name
    FROM     user_objects
    WHERE    status != 'VALID'
    ORDER BY object_type, object_name;
  v_compiles PLS_INTEGER := 0;
  v_errors   PLS_INTEGER := 0;
  v_status   user_objects.status%TYPE;
  v_sql      VARCHAR2(80);
  v_invalid  PLS_INTEGER;
BEGIN
  FOR r IN c_invalid LOOP
    SELECT status
    INTO   v_status
    FROM   user_objects
    WHERE  object_type = r.object_type
    AND    object_name = r.object_name;
    IF v_status != 'VALID' THEN
      IF r.object_type = 'PACKAGE' THEN
        v_sql := 'ALTER PACKAGE "' || r.object_name || 
                 '" COMPILE SPECIFICATION';
      ELSIF r.object_type = 'PACKAGE BODY' THEN
        v_sql := 'ALTER PACKAGE "' || r.object_name || '" COMPILE BODY';
      ELSE
        v_sql := 'ALTER ' || r.object_type || ' "' || r.object_name || 
                 '" COMPILE';
      END IF;
      BEGIN
        EXECUTE IMMEDIATE v_sql;
      EXCEPTION
        WHEN OTHERS THEN
          v_errors := v_errors + 1;
          dbms_output.put_line ('The following failed with ' || SQLERRM);
          dbms_output.put_line (v_sql);
      END;
      v_compiles := v_compiles + 1;
    END IF;
  END LOOP;
  SELECT COUNT(*)
  INTO   v_invalid
  FROM   user_objects
  WHERE  status != 'VALID';
  IF v_compiles = 1 THEN
    dbms_output.put_line ('1 object was compiled.');
  ELSE
    dbms_output.put_line (TO_CHAR (v_compiles) || ' objects were compiled.');
  END IF;
  IF v_errors > 1 THEN
    dbms_output.put_line (TO_CHAR (v_errors) || ' errors occurred during ' ||
                          'compilation.');
  ELSIF v_errors = 1 THEN
    dbms_output.put_line ('1 error occurred during compilation.');
  END IF;
  IF v_invalid > 1 THEN
    dbms_output.put_line (TO_CHAR (v_invalid) || ' objects remain invalid.');
  ELSIF v_invalid = 1 THEN
    dbms_output.put_line ('1 object remains invalid.');
  ELSE
    dbms_output.put_line ('All objects are now valid.');
  END IF;
END;
/

