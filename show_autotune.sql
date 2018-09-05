COLUMN parameter_value FORMAT A30

SELECT parameter_name, parameter_value
FROM   dba_advisor_parameters
WHERE  task_name = 'SYS_AUTO_SQL_TUNING_TASK'
AND    parameter_name IN ('ACCEPT_SQL_PROFILES',
                          'MAX_SQL_PROFILES_PER_EXEC',
                          'MAX_AUTO_SQL_PROFILES');


