#/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER admin;
    ALTER USER admin WITH PASSWORD 'data';
    CREATE USER lagerist;
    ALTER ROLE lagerist WITH PASSWORD 'logistik';
    CREATE USER abteilungsleiter;
    ALTER ROLE abteilungsleiter WITH PASSWORD 'prozess';
EOSQL
