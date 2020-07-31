#/bin/bash

set -e 

echo -n "Username: "
read user
sudo psql -U $user  -h localhost -p 5436 -d etm << EOSQL
set search_path to zustand1;
select s.standort_name as "Standort", l.lager_name as "Lagername", sum(anzahl*kosten) || ' €'as "Wert aller gelagerten Ersatzteile"
from standort s join lager l on (s.standort_id = l.standort_id)
                join lagerort lo on (l.lager_id = lo.lager_id)
                join ersatzteil e on (e.e_id = lo.e_id)
group by rollup(s.standort_name, l.lager_name);
\q
EOSQL
