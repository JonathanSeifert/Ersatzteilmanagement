#/bin/bash

set -e

#Systemadministrator
nutzer="admin"
pw_nutzer="data"
recht_nutzer="SUPERUSER" #alter role ... with recht_nutzer

#Lagerist
nutzer1="lagerist"
pw_nutzer1="logistik"

#Abteilungsleiter
nutzer2="abteilungsleiter"
pw_nutzer2="prozess"

#Nutzerarray
declare -a nutzer=($nutzer $nutzer1 $nutzer2)
nutzer_length=${#nutzer[@]}
#Passwordarray
declare -a pw=($pw_nutzer $pw_nutzer1 $pw_nutzer2)
pw_length=${#pw[@]}
#Datenbank
db="etm"
db_full="Ersatzteilmanagement"

#Zustaende
zustand1="zustand1"
zustand2="zustand2"
zustand3="zustand3"
declare -a zustand=($zustand1 $zustand2 $zustand3)
zustand_length=${#zustand[@]}

#Indexe
index1="anzahl_mindestbestand"
index2="kosten_eclass"

#Datenbank erstellen
echo -----------------------------------------------------------------------
echo Anzahl Zustaende: $zustand_length
echo Anzahl Nutzer: $nutzer_length
echo
echo Erstelle Datenbank $db "(Abkuerzung fuer $db_full)"
echo
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  CREATE DATABASE $db;
EOSQL
echo
#
#Schemaerstellung
echo Schemaerstellung
echo ----------------
for((i=0;i<$zustand_length;i++));
 do
   echo Erstelle ${zustand[$i]}
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  \connect $db
  CREATE SCHEMA ${zustand[$i]};
  SET SEARCH_PATH TO ${zustand[$i]};
  \i docker-entrypoint-initdb.d/sample/create.sql
EOSQL
  echo ${zustand[$i]} erstellt.
  echo
 done 

#Indexerstellung
echo Erstelle Index
echo ----------------
for ((i=0;i<$nutzer_length;i++));
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" << EOSQL
  \connect $db
    CREATE INDEX $index1 ON ${zustand[$i]}.lagerort(anzahl, mindestbestand) ;
	CREATE INDEX $index2 ON ${zustand[$i]}.ersatzteil(kosten, eclass);
EOSQL
  echo 
done
#Nutzererstellung
echo Nutzererstellung
echo ----------------
for ((i=0;i<$nutzer_length;i++));
do
  echo Erstelle Nutzer: ${nutzer[$i]}
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" << EOSQL
    CREATE USER ${nutzer[$i]} WITH PASSWORD '${pw[$i]}';
EOSQL
  echo Nutzer: ${nutzer[$i]} erstellt.
  echo 
done
#
#Rechtevergabe
echo Rechtevergabe
echo -------------
echo Allgemeine Rechte
echo
echo  Verteile allgemeine Rechte.
for ((i=0;i<$nutzer_length;i++));
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
    \connect $db
	GRANT CONNECT ON DATABASE $db to ${nutzer[$i]};
    GRANT pg_read_server_files TO ${nutzer[$i]};
    GRANT USAGE ON SCHEMA ${zustand[0]} TO ${nutzer[$i]};
    GRANT USAGE ON SCHEMA ${zustand[1]}  TO ${nutzer[$i]};
    GRANT USAGE ON SCHEMA ${zustand[2]}  TO ${nutzer[$i]};
EOSQL
done
echo Allgemeine Rechte verteilt
echo
echo Spezifische Rechte
echo
echo Verteile spezifische Rechte für ${nutzer[0]}
for ((i=0;i<$zustand_length;i++));
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
		\connect $db
		ALTER USER ${nutzer[0]} WITH $recht_nutzer;
		GRANT ALL PRIVILEGES ON SCHEMA ${zustand[$i]} TO ${nutzer[1]};
EOSQL
done
echo Spezifische Rechte für ${nutzer[0]} verteilt
echo
echo Verteile spezifische Rechte für ${nutzer[1]}
for ((i=0;i<$zustand_length;i++));
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
		\connect $db
		GRANT SELECT ON ALL TABLES IN SCHEMA ${zustand[$i]} TO ${nutzer[1]};
		REVOKE SELECT (kosten) on TABLE ${zustand[$i]}.ersatzteil FROM ${nutzer[1]};
		GRANT UPDATE (anzahl) ON TABLE ${zustand[$i]}.lagerort TO ${nutzer[1]};
EOSQL
done
echo Spezifische Rechte für ${nutzer[2]} verteilt
for ((i=0;i<$zustand_length;i++));
do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
		\connect $db
		GRANT SELECT ON ALL TABLES IN SCHEMA ${zustand[$i]} TO ${nutzer[2]};
		GRANT INSERT, UPDATE,  DELETE ON TABLE ${zustand[$i]}.lieferant TO ${nutzer[2]};
		GRANT INSERT, UPDATE,  DELETE ON TABLE ${zustand[$i]}.ersatzteil TO ${nutzer[2]};
		GRANT INSERT, UPDATE,  DELETE ON TABLE ${zustand[$i]}.lagerort TO ${nutzer[2]};
		GRANT ALL PRIVILEGES ON SEQUENCE ${zustand[$i]}.lieferant_id_seq TO ${nutzer[2]};
		GRANT ALL PRIVILEGES ON SEQUENCE ${zustand[$i]}.e_id_seq TO ${nutzer[2]};
		GRANT ALL PRIVILEGES ON SEQUENCE ${zustand[$i]}.lagerort_id_seq TO ${nutzer[2]};
		
EOSQL
done
echo Spezifische Rechte für ${nutzer[2]} verteilt
echo
echo Zustandsbefuellung
echo ------------------
echo
echo Befuele ${zustand[0]}
psql -v ON_ERRROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
\connect $db
SET SEARCH_PATH TO ${zustand[0]};
\i docker-entrypoint-initdb.d/sample/zustand_1.sql
EOSQL
echo ${zustand[0]} befuellt.
echo
echo Befuele ${zustand[1]}
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
\connect $db
SET SEARCH_PATH TO ${zustand[1]};
\i docker-entrypoint-initdb.d/sample/zustand_2.sql;
EOSQL
echo ${zustand[2]} befuellt.
echo Befuele ${zustand[2]}
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
\connect $db
SET SEARCH_PATH TO ${zustand[2]};
--\i docker-entrypoint-initdb.d/sample/zustand_3.sql;
EOSQL
echo ${zustand[2]} befuellt.
echo -----------------------------------------------------------------------
