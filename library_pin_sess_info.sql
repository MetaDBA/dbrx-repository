tti "Blocking/Waiting Users"
col SID_SERIAL format a12
SELECT s.sid||','||s.serial# SID_SERIAL, kglpnmod "Mode Held", kglpnreq "Request"
  FROM sys.x$kglpn p, sys.v_$session s
 WHERE p.kglpnuse = s.saddr
   AND kglpnhdl   = '&P1RAW';


