#/bin/bash

set -e 

echo -n "Username: "
read user
sudo psql -U $user  -h localhost -p 5436 -d etm << EOSQL
set search_path to zustand1;
with recursive max as (

	select max(lieferant_id) as max

	from lieferant

),

rec as (

	select distinct a.abteilung_id, cast(l.lieferant_id as integer), l.lieferant_name

 	from lieferant l join ersatzteil e on (e.lieferant_id = l.lieferant_id)

	    join zuordnung z on (z.e_id = e.e_id)

            join abteilung a on (a.abteilung_id = z.abteilung_id)

	    join standort s on (s.standort_id = a.standort_id)

	where s.standort_id = '10' and l.lieferant_id = 1

	union

	select distinct a.abteilung_id, cast(l.lieferant_id+1 as integer), l.lieferant_name

 	from lieferant l join ersatzteil e on (e.lieferant_id = l.lieferant_id)

	    join zuordnung z on (z.e_id = e.e_id)

            join abteilung a on (a.abteilung_id = z.abteilung_id)

	    join standort s on (s.standort_id = a.standort_id), max m, rec r 

	where s.standort_id = '10' and l.lieferant_id<m.max) 

select a.abteilung_name as "Abteilung", r.abteilung_id as "ID", string_agg(distinct r.lieferant_name, ', ') as "Lieferanten"
from rec r join abteilung a on (a.abteilung_id = r.abteilung_id) 
group by r.abteilung_id, a.abteilung_name order by r.abteilung_id asc;
\q
EOSQL
