BEGIN
   DBMS_DEFER_SYS.DELETE_ERROR(
      null,
      destination => 'PRODAZ.WELLSFARGO.COM');
END;
/

