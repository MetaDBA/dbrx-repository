create or replace FUNCTION FULLDATE
	   	  		  (in_date IN date) 
RETURN VARCHAR2 IS 
/******************************************************************************
   NAME:       FULLDATE
   PURPOSE:    To display a date field as DD-MON-YYYY HH24:MI:SS.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/17/99   Terry A. Sutton  1. Created this function.

   PARAMETERS:
   INPUT:
   OUTPUT:
   RETURNED VALUE:  VARCHAR2
   CALLED BY:
   CALLS:
   EXAMPLE USE:     VARCHAR2 := FULLDATE(in_date);
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:
******************************************************************************/

BEGIN
   RETURN to_char(in_date,'DD-MON-YYYY HH24:MI:SS');
END FULLDATE;
