-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename           : osmtitle.sql - Version 1.0
-- * Author             : Craig A. Shallahamer
-- * Original           : 17-AUG-98
-- * Last Update        : 17-AUG-98
-- * Description        : Standard OSM title header
-- * Usage              : start osmtitle.sql
-- ********************************************************************

set termout off

break on today
col today new_value now
select to_char(sysdate, 'DD-MON-YY HH:MI:SSam') today 
from   dual;

col val1 new_value db noprint
select value val1 
from   v$parameter 
where  name = 'db_name';

clear breaks
set termout on
set heading on
set linesize 132

ttitle -
    left 'Database: &db'        right now              skip 0 -
    left 'Report:   &osm_prog'  center 'OSM by OraPub, Inc.' - 
    right 'Page' sql.pno                               skip 1 -
    center '&osm_title'                                skip 2

