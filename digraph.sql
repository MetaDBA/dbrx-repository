/*

Copyright 2009 Iggy Fernandez

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

SET linesize 1000
SET trimspool on
SET pagesize 0
SET echo off
SET heading off
SET feedback off
SET verify off
SET time off
SET timing off
SET sqlblanklines on

DEFINE sql_id = &sql_id
DEFINE child_number = &child_number

SPOOL plan.dot

WITH
plan_table AS
(
  SELECT
    *
  FROM
    TABLE (enhanced_plan.plan (
      '&sql_id',
      &child_number
    ))
)
SELECT
  'digraph a { node[fontname=Arial]'
    AS dot_command
FROM
  DUAL
UNION ALL
SELECT
  '"'
  || id
  || '" [label="Step '
  || execution_id
  || '\n'
  || CASE WHEN object_name IS NULL
    THEN ('')
    ELSE (object_name || '\n')
    END
  || CASE WHEN options IS NULL
    THEN (operation || '\n')
    ELSE (operation || ' ' || options || '\n')
    END
  || 'Elapsed Delta = '
  || TRIM (TO_CHAR (delta_elapsed_time, '999,999,990.00'))
  || 's'
  || ' Total Elapsed = '
  || TRIM (TO_CHAR (last_elapsed_time, '999,999,990.00'))
  || 's\n'
  || 'Estimated Rows = '
  || TRIM (TO_CHAR (cardinality, '999,999,999,999,990'))
  || ' Actual Rows = '
  || TRIM (TO_CHAR (last_output_rows, '999,999,999,999,990'))
  || '\n'
  || 'Logical Reads = '
  || TRIM (TO_CHAR (last_logical_reads, '999,999,999,999,990'))
  || ' Physical Reads = '
  || TRIM (TO_CHAR (last_disk_reads, '999,999,999,999,990'))
  || '",shape=plaintext]'
    AS dot_command
FROM
  plan_table
UNION ALL
SELECT
  dot_command
FROM
  (
    SELECT
      parent_id,
      '"' || id || '"' || '->' || '"' || PRIOR id || '"' || ';'
        AS dot_command
    FROM
      plan_table
      START WITH parent_id = 0
      CONNECT BY parent_id = PRIOR id
  )
  WHERE
    parent_id IS NOT NULL
UNION ALL
SELECT
  '};'
FROM
  DUAL;

SPOOL off

UNDEFINE sql_id
UNDEFINE child_number

