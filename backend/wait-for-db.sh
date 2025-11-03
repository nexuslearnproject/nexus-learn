#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

# Wait for PostgreSQL to be ready
until PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U "${POSTGRES_USER}" -d "postgres" -c '\q' 2>/dev/null; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

# Check if the target database exists, if not create it
PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U "${POSTGRES_USER}" -d "postgres" -tc "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}'" | grep -q 1 || \
PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U "${POSTGRES_USER}" -d "postgres" -c "CREATE DATABASE ${POSTGRES_DB}"

# Wait for the target database to be ready
until PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c '\q' 2>/dev/null; do
  >&2 echo "Database ${POSTGRES_DB} is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL database ${POSTGRES_DB} is up - executing command"
exec $cmd

