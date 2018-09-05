REM
REM compare_data.sql
REM ================
REM
REM This script is provided by Database Specialists, Inc. 
REM (http://www.dbspecialists.com) for individual use and not for sale. 
REM Database Specialists, Inc. does not warrant the script in any way 
REM and will not be responsible for any loss arising out of its use.
REM
REM Your feedback is welcome! Please send your comments about this script
REM to scriptfeedback@dbspecialists.com
REM
REM This script will compare the data in tables of the local Oracle schema
REM to identically named tables in a remote Oracle schema and generate a 
REM report of data discrepencies. For each table not containing identical
REM rows in the two schemas, the report will include a SQL query you can
REM run to display all of the differing data.
REM
REM You can easily customize this script to only compare data in certain 
REM tables, and also to exclude certain columns within each table from the 
REM comparison.
REM
REM Please note that the only way to compare data in tables is to read all
REM of the data from each table. Although this script is pretty efficient
REM in the way it does the comparison, comparing the contents of large tables
REM can be resource intensive and can impact response time for other users.
REM If you will be using this script to compare large volumes of data, please
REM take this into consideration.
REM
REM Oracle 8 and Oracle 8i do not support fetching LOBs from remote tables,
REM so data in LOB columns are not compared by this script. For similar 
REM reasons, LONGs and LONG RAWs are not compared, either. Tables containing
REM LOB or LONG columns will be compared, but data in the LOB and LONG columns
REM will be left out of the comparison.
REM
REM Version 02-06-2002
REM

REM
REM Edit the following three DEFINE statements to customize this script 
REM to suit your needs. 
REM

REM Tables to be compared:

prompt "What table"

DEFINE table_criteria = "table_name = upper('&what_table')"
REM DEFINE table_criteria = "table_name = table_name" -- all tables
REM DEFINE table_criteria = "table_name != 'TEST'"
REM DEFINE table_criteria = "table_name LIKE 'LOOKUP%' OR table_name LIKE 'C%'"

REM Columns to be compared:

DEFINE column_criteria = "column_name = column_name" -- all columns
REM DEFINE column_criteria = "column_name NOT IN ('CREATED', 'MODIFIED')"
REM DEFINE column_criteria = "column_name NOT LIKE '%_ID'"

REM Database link to be used to access the remote schema:

DEFINE dblink = "prccinc"

SET SERVEROUTPUT ON SIZE 1000000
SET VERIFY OFF

DECLARE
  CURSOR c_tables IS
    SELECT   table_name
    FROM     user_tables
    WHERE    &table_criteria
    ORDER BY table_name;
  CURSOR c_columns (cp_table_name IN VARCHAR2) IS
    SELECT   column_name, data_type
    FROM     user_tab_columns
    WHERE    table_name = cp_table_name
    AND      &column_criteria
    ORDER BY column_id;
  TYPE t_char80array IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  v_column_list     VARCHAR2(32767);
  v_total_columns   INTEGER;
  v_skipped_columns INTEGER;
  v_count1          INTEGER;
  v_count2          INTEGER;
  v_rows_fetched    INTEGER;
  v_column_pieces   t_char80array;
  v_piece_count     INTEGER;
  v_pos             INTEGER;
  v_length          INTEGER;
  v_next_break      INTEGER;
  v_same_count      INTEGER := 0;
  v_diff_count      INTEGER := 0;
  v_error_count     INTEGER := 0;
  v_warning_count   INTEGER := 0;
  --
  -- Use dbms_sql instead of native dynamic SQL so that Oracle 7 and Oracle 8
  -- folks can use this script.
  --
  v_cursor          INTEGER := dbms_sql.open_cursor;
  --
BEGIN
  --
  -- Iterate through all tables in the local database that match the
  -- specified table criteria.
  --
  FOR r1 IN c_tables LOOP
    --
    -- Build a list of columns that we will compare (those columns
    -- that match the specified column criteria). We will skip columns
    -- that are of a data type not supported (LOBs and LONGs).
    --
    v_column_list := NULL;
    v_total_columns := 0;
    v_skipped_columns := 0;
    dbms_output.put_line(r1.table_name);
    FOR r2 IN c_columns (r1.table_name) LOOP
      v_total_columns := v_total_columns + 1;
      IF r2.data_type IN ('BLOB', 'CLOB', 'NCLOB', 'LONG', 'LONG RAW') THEN
        --
        -- The column's data type is one not supported by this script (a LOB
        -- or a LONG). We'll enclose the column name in comment delimiters in
        -- the column list so that the column is not used in the query.
        --
        v_skipped_columns := v_skipped_columns + 1;
        IF v_column_list LIKE '%,' THEN
          v_column_list := RTRIM (v_column_list, ',') || 
                           ' /*, "' || r2.column_name || '" */,';
        ELSE
          v_column_list := v_column_list || ' /* "' || r2.column_name ||'" */ ';
        END IF;
      ELSE
        --
        -- The column's data type is supported by this script. Add the column
        -- name to the column list for use in the data comparison query.
        --
        v_column_list := v_column_list || '"' || r2.column_name || '",';
      END IF;
    END LOOP;
    --
    -- Compare the data in this table only if it contains at least one column
    -- whose data type is supported by this script.
    --
    IF v_total_columns > v_skipped_columns THEN 
      --
      -- Trim off the last comma from the column list.
      --
      v_column_list := RTRIM (v_column_list, ',');
      BEGIN
        --
        -- Get a count of rows in the local table missing from the remote table.
        --
        dbms_sql.parse 
        (
        v_cursor,
        'SELECT COUNT(*) FROM (' ||
        'SELECT ' || v_column_list || ' FROM "' || r1.table_name || '"' ||
        ' MINUS ' ||
        'SELECT ' || v_column_list || ' FROM "' || r1.table_name ||'"@&dblink)',
        dbms_sql.native
        );
        dbms_sql.define_column (v_cursor, 1, v_count1);
        v_rows_fetched := dbms_sql.execute_and_fetch (v_cursor);
        IF v_rows_fetched = 0 THEN
          RAISE NO_DATA_FOUND;
        END IF;
        dbms_sql.column_value (v_cursor, 1, v_count1);
        --
        -- Get a count of rows in the remote table missing from the local table.
        --
        dbms_sql.parse 
        (
        v_cursor,
        'SELECT COUNT(*) FROM (' ||
        'SELECT ' || v_column_list || ' FROM "' || r1.table_name ||'"@&dblink'||
        ' MINUS ' ||
        'SELECT ' || v_column_list || ' FROM "' || r1.table_name || '")',
        dbms_sql.native
        );
        dbms_sql.define_column (v_cursor, 1, v_count2);
        v_rows_fetched := dbms_sql.execute_and_fetch (v_cursor);
        IF v_rows_fetched = 0 THEN
          RAISE NO_DATA_FOUND;
        END IF;
        dbms_sql.column_value (v_cursor, 1, v_count2);
        --
        -- Display our findings.
        --
        IF v_count1 = 0 AND v_count2 = 0 THEN
          --
          -- No data discrepencies were found. Report the good news.
          --
          dbms_output.put_line 
          (
          r1.table_name || ' - Local and remote table contain the same data'
          );
          v_same_count := v_same_count + 1;
          IF v_skipped_columns = 1 THEN
            dbms_output.put_line
            (
            r1.table_name || ' - Warning: 1 LOB or LONG column was omitted ' ||
            'from the comparison'
            );
            v_warning_count := v_warning_count + 1;
          ELSIF v_skipped_columns > 1 THEN
            dbms_output.put_line
            (
            r1.table_name || ' - Warning: ' || TO_CHAR (v_skipped_columns) ||
            ' LOB or LONG columns were omitted from the comparison'
            );
            v_warning_count := v_warning_count + 1;
          END IF;
        ELSE
          --
          -- There is a discrepency between the data in the local table and
          -- the remote table. First, give a count of rows missing from each.
          --
          IF v_count1 > 0 THEN
            dbms_output.put_line 
            (
            r1.table_name || ' - ' ||
            LTRIM (TO_CHAR (v_count1, '999,999,990')) ||
            ' rows on local database missing from remote'
            );
          END IF;
          IF v_count2 > 0 THEN
            dbms_output.put_line 
            (
            r1.table_name || ' - ' ||
            LTRIM (TO_CHAR (v_count2, '999,999,990')) ||
            ' rows on remote database missing from local'
            );
          END IF;
          IF v_skipped_columns = 1 THEN
            dbms_output.put_line
            (
            r1.table_name || ' - Warning: 1 LOB or LONG column was omitted ' ||
            'from the comparison'
            );
            v_warning_count := v_warning_count + 1;
          ELSIF v_skipped_columns > 1 THEN
            dbms_output.put_line
            (
            r1.table_name || ' - Warning: ' || TO_CHAR (v_skipped_columns) ||
            ' LOB or LONG columns were omitted from the comparison'
            );
            v_warning_count := v_warning_count + 1;
          END IF;
          --
          -- Next give the user a query they could run to see all of the
          -- differing data between the two tables. To prepare the query,
          -- first we'll break the list of columns in the table into smaller
          -- chunks, each short enough to fit on one line of a telnet window
          -- without wrapping.
          --
          v_pos := 1;
          v_piece_count := 0;
          v_length := LENGTH (v_column_list);
          LOOP
            EXIT WHEN v_pos = v_length;
            v_piece_count := v_piece_count + 1;
            IF v_length - v_pos < 72 THEN
              v_column_pieces(v_piece_count) := SUBSTR (v_column_list, v_pos);
              v_pos := v_length;
            ELSE
              v_next_break := 
                GREATEST (INSTR (SUBSTR (v_column_list, 1, v_pos + 72),
                                 ',"', -1),
                          INSTR (SUBSTR (v_column_list, 1, v_pos + 72),
                                 ',/* "', -1),
                          INSTR (SUBSTR (v_column_list, 1, v_pos + 72),
                                 ' /* "', -1));
              v_column_pieces(v_piece_count) := 
                SUBSTR (v_column_list, v_pos, v_next_break - v_pos + 1);
              v_pos := v_next_break + 1;
            END IF;
          END LOOP;
          dbms_output.put_line ('Use the following query to view the data ' ||
                                'discrepencies:');
          dbms_output.put_line ('(');
          dbms_output.put_line ('SELECT ''Local'' "LOCATION",');
          FOR i IN 1..v_piece_count LOOP
            dbms_output.put_line (v_column_pieces(i));
          END LOOP;
          dbms_output.put_line ('FROM "' || r1.table_name || '"');
          dbms_output.put_line ('MINUS');
          dbms_output.put_line ('SELECT ''Local'' "LOCATION",');
          FOR i IN 1..v_piece_count LOOP
            dbms_output.put_line (v_column_pieces(i));
          END LOOP;
          dbms_output.put_line ('FROM "' || r1.table_name || '"@&dblink');
          dbms_output.put_line (') UNION ALL (');
          dbms_output.put_line ('SELECT ''Remote'' "LOCATION",');
          FOR i IN 1..v_piece_count LOOP
            dbms_output.put_line (v_column_pieces(i));
          END LOOP;
          dbms_output.put_line ('FROM "' || r1.table_name || '"@&dblink');
          dbms_output.put_line ('MINUS');
          dbms_output.put_line ('SELECT ''Remote'' "LOCATION",');
          FOR i IN 1..v_piece_count LOOP
            dbms_output.put_line (v_column_pieces(i));
          END LOOP;
          dbms_output.put_line ('FROM "' || r1.table_name || '"');
          dbms_output.put_line (');');
          v_diff_count := v_diff_count + 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- An error occurred while processing this table. (Most likely it 
          -- doesn't exist or has fewer columns on the remote database.)
          -- Show the error we encountered on the report.
          --
          dbms_output.put_line (r1.table_name || ' - ' || SQLERRM);
          v_error_count := v_error_count + 1;
      END;
    END IF;
  END LOOP;
  --
  -- Print summary information.
  --
  dbms_output.put_line ('-------------------------------------------------');
  dbms_output.put_line 
  (
  'Tables examined: ' || TO_CHAR (v_same_count + v_diff_count + v_error_count)
  );
  dbms_output.put_line 
  (
  'Tables with data discrepencies: ' || TO_CHAR (v_diff_count)
  );
  IF v_warning_count > 0 THEN
    dbms_output.put_line 
    (
    'Tables with warnings: ' || TO_CHAR(v_warning_count)
    );
  END IF;
  IF v_error_count > 0 THEN
    dbms_output.put_line 
    (
    'Tables that could not be checked due to errors: ' || TO_CHAR(v_error_count)
    );
  END IF;
  dbms_sql.close_cursor (v_cursor);
END;
/
