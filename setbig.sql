alter session set sort_area_size=2000000000;
alter session enable parallel dml;
ALTER SESSION SET WORKAREA_SIZE_POLICY=MANUAL;

