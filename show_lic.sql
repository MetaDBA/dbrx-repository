SELECT INSTANCE_NAME,SESSIONS_CURRENT,SESSIONS_HIGHWATER,cpu_count_current,cpu_core_count_current,cpu_socket_count_current
  FROM GV$LICENSE l , GV$INSTANCE i 
where l.INST_ID=i.INST_ID;
