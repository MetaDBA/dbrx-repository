tti "Object that is Blocking"
COL owner format a8
COL object format a70
SELECT kglnaown AS owner, kglnaobj as Object
  FROM sys.x$kglob
 WHERE kglhdadr='&P1RAW';
