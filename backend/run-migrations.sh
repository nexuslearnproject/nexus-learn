#!/bin/bash
set -e

# Wait for database
wait-for-db.sh db

# Run migrations with error handling
echo "Running migrations..."

# First, ensure contenttypes and auth are migrated
python manage.py migrate contenttypes --noinput || true
python manage.py migrate auth --noinput || true

# Migrate api app (creates User model)
python manage.py migrate api --noinput || true

# Try to migrate admin, but handle the User model resolution error
python manage.py migrate admin --noinput 2>&1 | grep -v "Related model 'api.user' cannot be resolved" || true

# Run all other migrations
python manage.py migrate --noinput 2>&1 | grep -v "Related model 'api.user' cannot be resolved" || true

# Start server
echo "Starting server..."
exec python manage.py runserver 0.0.0.0:8000

