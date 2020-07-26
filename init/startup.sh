#/bin/bash

set -e

#Systemadministrator
admin="systemadministrator"
pwadmin="data"

#Lagerist
nutzer1="lagerist"
pwnutzer1="logistik"

#Abteilungsleiter
nutzer2="abteilungsleiter"
pwnutzer2="prozess"

#Datenbank
db="etm"

#Zustaende
declare -a array=("zustand1" "zustand2" "zustand3")
arraylength=${#array[@]}

#Datenbank erstellen
echo Erstelle Nutzer.
for i in $admin $nutzer1 $nutzer2
 do
  echo Erstelle Nutzer: $i
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" << EOSQL
    CREATE USER $i;
EOSQL
  echo Nutzer: $i erstellt.
done
