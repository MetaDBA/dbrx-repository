-- ********************************************************************
-- * Copyright Notice   : (c)1998 OraPub, Inc.
-- * Filename           : cu.sql - Version 1.0
-- * Author             : Craig A. Shallahamer
-- * Original		: 17-AUG-98
-- * Last Modified	: 17-AUG-98
-- * Description	: Create a user with a:
-- *					1. Role
-- *					2. Default tablespace
-- *			  		3. Temporary tablespace
-- *					4. Profile
-- * Usage		: start cu <un> <pd> <dflt tbs> <tmp tbs> <prof>
-- ********************************************************************


def orauid	= &&1
def pswd	= &&2
def dts		= &&3
def tts		= &&4
def prof	= &&5

create user 		&orauid
  identified by 	&pswd
  default tablespace 	&dts 
  temporary tablespace 	&tts
  profile		&prof
/

alter user &orauid quota 0 on system;

alter user &orauid quota unlimited on &dts;
  
grant connect to &orauid;

undef orauid
undef pswd
undef dts
undef tts
undef prof
start osmclear

