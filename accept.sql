-------------------------------------------------------------------------------
--
-- Script:	accept.sql
-- Purpose:	to prompt for a script parameter, but allow a default value
--
-- Copyright:	(c) Ixora Pty Ltd
-- Author:	Steve Adams
--
-- Synopsis:	@accept name prompt default
--
-------------------------------------------------------------------------------

accept _value_entered prompt "&2 [&3] "
column _value_returned new_value &1 noprint
set termout off
select nvl('&_value_entered', '&3') "_value_returned" from dual;
set termout on
undefine 1 2 3 _value_entered
column _value_returned clear
