-- ********************************************************************
-- * Copyright Notice   : (c)1999 OraPub, Inc.
-- * Filename		: hashchk.sql - Version 1.0
-- * Author		: John Beresniewicz, Craig Shallahamer
-- * Original		: 05-MAY-99
-- * Last Update	: 05-MAY-99
-- * Description	: Checks if all hash values in v$sqlarea
-- *			  have an entry in v$sqltext.
-- * Usage		: start hashchk.sql
-- ********************************************************************

def osm_prog	= 'hashchk.sql'
def osm_title	= 'V$SQLAREA and  V$SQLTEXT Hash Value Check'
start osmtitle

col hash  format  999999999999	heading 'Hash Value'
col text  format           a60	heading 'Statement Text (Partial)' trunc

select	sa.hash_value	hash,
	sa.sql_text	text
from 	v$sqlarea sa,
        (select hash_value 
	 from   v$sqlarea
         minus
	 select hash_value 
	 from v$sqltext
	 ) hv
where	hv.hash_value = sa.hash_value
/

start osmclear

