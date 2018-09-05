col bytes for 9,999,999,999,999
select KSMCHIDX "# of SubPools", sum(ksmchsiz) Bytes 
from x$ksmsp
group by ksmchidx order by 1;

