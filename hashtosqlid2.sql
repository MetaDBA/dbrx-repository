select
    trunc(mod(sum((
        instr('0123456789abcdfghjkmnpqrstuvwxyz',substr(lower(trim('&1')),level,1))-1)*power(32,length(trim('&1'))-level)),power(2,32))) hash_value
    , lower(trim'&1')) sql_id
from
    dual
connect by
    level <= length(trim('&1'));

