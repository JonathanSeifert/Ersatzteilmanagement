#/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER Admin;
    ALTER USER Admin WITH PASSWORD '07c19';
EOSQL

