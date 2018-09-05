col parameter_name for a40 trunc
col parameter_value for a40 trunc
set linesize 1000
select audit_trail,parameter_name,parameter_value from dba_audit_mgmt_config_params order by 1;

col user_name for a10
col proxy_name for a10 trunc
col audit_option for a40
col success for a10
col failuer for a10

select * from dba_stmt_audit_opts;
select * from dba_priv_audit_opts;

