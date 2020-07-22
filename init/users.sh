#/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER Administrator;
    ALTER USER Administrator  WITH PASSWORD 'Admin123@';
EOSQL

