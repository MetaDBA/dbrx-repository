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

SET echo on

DROP TYPE enhanced_plan_table;

CREATE OR REPLACE TYPE enhanced_plan_type
AS OBJECT
(
  execution_id NUMBER,
  operation VARCHAR2 (120),
  options VARCHAR2 (120),
  object_owner VARCHAR2 (30),
  object_name VARCHAR2 (30),
  id NUMBER,
  parent_id NUMBER,
  cardinality NUMBER,
  last_output_rows NUMBER,
  last_logical_reads NUMBER,
  last_disk_reads NUMBER,
  last_elapsed_time NUMBER,
  delta_elapsed_time NUMBER
);
/

SHOW ERRORS;

CREATE OR REPLACE TYPE enhanced_plan_table
AS TABLE OF enhanced_plan_type
/

CREATE OR REPLACE PACKAGE enhanced_plan
AS
  FUNCTION plan
  (
    sql_id_in VARCHAR2,
    child_number_in NUMBER,
    parent_id_in NUMBER DEFAULT 0
  )
  RETURN enhanced_plan_table PIPELINED;
END enhanced_plan;
/

SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY enhanced_plan AS

  FUNCTION PLAN
  (
    sql_id_in VARCHAR2,
    child_number_in NUMBER,
    parent_id_in NUMBER DEFAULT 0
  )
  RETURN enhanced_plan_table PIPELINED
  IS

    parent_row enhanced_plan_type := enhanced_plan_type
    (
      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL
    );

    child_row enhanced_plan_type := enhanced_plan_type
    (
      NULL, NULL, NULL, NULL, NULL, NULL, NULL,
      NULL, NULL, NULL, NULL, NULL, NULL
    );

    execution_id NUMBER := 1;

    CURSOR parent_cursor IS
    WITH
    parent_statistics AS
    (
      SELECT
        operation,
        options,
        object_owner,
        object_name,
        id,
        parent_id,
        cardinality,
        last_output_rows,
        last_cr_buffer_gets + last_cu_buffer_gets
          AS last_logical_reads,
        last_disk_reads,
        last_elapsed_time / 1000000
          AS last_elapsed_time
      FROM
        v$sql_plan_statistics_all
       WHERE
        sql_id = sql_id_in
        AND child_number = child_number_in
        AND parent_id = parent_id_in
    ),
    child_statistics AS
    (
      SELECT
        parent_id,
        SUM (last_cr_buffer_gets + last_cu_buffer_gets)
          AS last_logical_reads,
        SUM (last_disk_reads) AS last_disk_reads,
        SUM (last_elapsed_time) / 1000000
          AS last_elapsed_time
      FROM
        v$sql_plan_statistics_all
      WHERE sql_id = sql_id_in
      AND child_number = child_number_in
      GROUP BY parent_id
    )
    SELECT
      p.operation,
      p.options,
      p.object_owner,
      p.object_name,
      p.ID,
      p.parent_id,
      p.cardinality,
      p.last_output_rows,
      p.last_logical_reads - NVL (c.last_logical_reads, 0)
        AS last_logical_reads,
      p.last_disk_reads - NVL (c.last_disk_reads, 0)
        AS last_disk_reads,
      p.last_elapsed_time AS last_elapsed_time,
      (p.last_elapsed_time - NVL (c.last_elapsed_time, 0))
        AS delta_elapsed_time
    FROM parent_statistics p, child_statistics c
    WHERE p.ID = c.parent_id(+)
    ORDER BY p.ID;

    CURSOR child_cursor IS
    SELECT
      operation,
      options,
      object_owner,
      object_name,
      ID,
      parent_id,
      cardinality,
      last_output_rows,
      last_logical_reads,
      last_disk_reads,
      last_elapsed_time,
      delta_elapsed_time
    FROM TABLE (enhanced_plan.plan (
      sql_id_in,
      child_number_in,
      parent_row.ID
    ));

  BEGIN

    OPEN parent_cursor;
    LOOP
      FETCH parent_cursor
      INTO
        parent_row.operation,
        parent_row.options,
        parent_row.object_owner,
        parent_row.object_name,
        parent_row.ID,
        parent_row.parent_id,
        parent_row.cardinality,
        parent_row.last_output_rows,
        parent_row.last_logical_reads,
        parent_row.last_disk_reads,
        parent_row.last_elapsed_time,
        parent_row.delta_elapsed_time;
      EXIT WHEN parent_cursor%NOTFOUND;
      OPEN child_cursor;
      LOOP
        FETCH child_cursor
        INTO
          child_row.operation,
          child_row.options,
          child_row.object_owner,
          child_row.object_name,
          child_row.ID,
          child_row.parent_id,
          child_row.cardinality,
          child_row.last_output_rows,
          child_row.last_logical_reads,
          child_row.last_disk_reads,
          child_row.last_elapsed_time,
          child_row.delta_elapsed_time;
        EXIT WHEN child_cursor%NOTFOUND;
        child_row.execution_id := execution_id;
        execution_id := execution_id + 1;
        PIPE ROW (child_row);
      END LOOP;
      CLOSE child_cursor;
      parent_row.execution_id := execution_id;
      execution_id := execution_id + 1;
      PIPE ROW (parent_row);
    END LOOP;
    CLOSE parent_cursor;

  END plan;

END enhanced_plan;
/

