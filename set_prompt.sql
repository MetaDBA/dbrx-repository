-------------------------------------------------------------------------------
--
-- Script:      set_prompt.sql
-- Purpose:     to include the user and instance in the SQL*Plus prompt
--
-- Copyright:   (c) Ixora Pty Ltd
-- Author:      Steve Adams
--
-- This script can be called from your login.sql or 
-- glogin.sql files to set the prompt in SQL*Plus 
-- so that it is preceded by a line showing the current 
-- user name and instance, as follows: 
-- 
-- STEVE@PROD:
-- SQL> 
-- 
-------------------------------------------------------------------------------
define Prompt = "SQL> "
column prompt new_value Prompt

set termout off
set time on
select
   user || '@' || instance_name || '/' || host_name|| ':' || chr(10) || 'SQL> '  prompt
from
  sys.v_$instance
/

alter session set nls_date_format='DD-MON-YY HH24:MI:SS';
alter session set cursor_sharing='EXACT';
col bytes form 999,999,999,999,999

set termout on
set sqlprompt "&Prompt"
