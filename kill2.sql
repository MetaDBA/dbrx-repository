20:48:46 DBADMIN@LIST:
SQL> select 'alter system kill session ''' || sid || ',' || serial# || ''';'
20:49:02   2  from v$session
20:49:02   3  where username = 'LISTAPP'
20:49:02   4  and status = 'ACTIVE'
20:49:02   5  order by sid desc;

'ALTERSYSTEMKILLSESSION'''||SID||','||SERIAL#||''';'                                                                                
--------------------------------------------------------------------------------------------------------------                      
alter system kill session '265,4839';                                                                                               
alter system kill session '264,534';                                                                                                
alter system kill session '256,1789';                                                                                               
alter system kill session '254,8075';                                                                                               
alter system kill session '249,5221';                                                                                               
alter system kill session '246,9167';                                                                                               
alter system kill session '245,3069';                                                                                               
alter system kill session '238,6084';                                                                                               
alter system kill session '234,20215';                                                                                              
alter system kill session '226,55983';                                                                                              
alter system kill session '223,44956';                                                                                              

'ALTERSYSTEMKILLSESSION'''||SID||','||SERIAL#||''';'                                                                                
--------------------------------------------------------------------------------------------------------------                      
alter system kill session '218,39577';                                                                                              
alter system kill session '207,23599';                                                                                              
alter system kill session '194,37101';                                                                                              
alter system kill session '190,56185';                                                                                              
alter system kill session '182,41904';                                                                                              
alter system kill session '173,19933';                                                                                              
alter system kill session '171,3302';                                                                                               
alter system kill session '162,49315';                                                                                              
alter system kill session '160,17733';                                                                                              
alter system kill session '134,4225';                                                                                               
alter system kill session '132,6623';                                                                                               

'ALTERSYSTEMKILLSESSION'''||SID||','||SERIAL#||''';'                                                                                
--------------------------------------------------------------------------------------------------------------                      
alter system kill session '128,39137';                                                                                              
alter system kill session '120,51543';                                                                                              
alter system kill session '118,41516';                                                                                              

25 rows selected.

20:49:03 DBADMIN@LIST:
SQL> spool off
