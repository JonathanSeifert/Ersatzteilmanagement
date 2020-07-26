#/bin/bash

set -e

#Systemadministrator
nutzer="admin"
pw_nutzer="data"

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

#Zustaende
declare -a zustand=("zustand1" "zustand2" "zustand3")
zustand_length=${#array[@]}

#Datenbank erstellen
echo ---------------------------------------------------------------------------
echo Erstelle Datenbank $db "(Abkuerzung fuer Ersatzteilmanagement)"
echo
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  CREATE DATABASE $db;
EOSQL
echo

#Schemaerstellung
echo Schemaerstellung
echo ----------------
  echo Erstelle Zustand_1.
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  CREATE SCHEMA zustand1;
  SET SEARCH_PATH TO zustand1;
  \i docker-entrypoint-initdb.d/sample/create.sql
EOSQL
  echo Zustand _1 erstellt.
  echo 
  echo Erstelle Zustand_2.
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  CREATE SCHEMA zustand2;
  SET SEARCH_PATH TO zustand2;
  \i docker-entrypoint-initdb.d/sample/create.sql
EOSQL
  echo Zustand_3 erstellt.
    echo 
  echo Erstelle Zustand_2.
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" << EOSQL
  CREATE SCHEMA zustand3;
  SET SEARCH_PATH TO zustand3;
  \i docker-entrypoint-initdb.d/sample/create.sql
EOSQL
  echo Zustand_3 erstellt.
echo
 
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

