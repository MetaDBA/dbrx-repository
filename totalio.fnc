CREATE OR REPLACE FUNCTION TOTALIO RETURN NUMBER IS
totio NUMBER;
/******************************************************************************
   NAME:       TOTALIO
   PURPOSE:    To calculate the desired information.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2/10/00          1. Created this function.

   PARAMETERS:
   INPUT:
   OUTPUT:
   RETURNED VALUE:  NUMBER
   CALLED BY:
   CALLS:
   EXAMPLE USE:     NUMBER := TOTALIO();
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:

   Here is the complete list of available Auto Replace Keywords:
      Object Name:     TOTALIO or TOTALIO
      Sysdate:         2/10/00
      Date/Time:       2/10/00 3:44:50 PM
      Date:            2/10/00
      Time:            3:44:50 PM
      Username:         (set in TOAD Options, Procedure Editor)
******************************************************************************/

CURSOR find_the_total is
	   select sum(phyblkrd) + sum(phyblkwrt)
  	   from  v$filestat fs;
BEGIN
   OPEN find_the_total;
   FETCH find_the_total INTO totio;
   CLOSE find_the_total;

   RETURN totio;
END TOTALIO;
/

