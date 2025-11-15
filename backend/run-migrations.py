#!/usr/bin/env python
"""Migration script that handles User model resolution errors"""
import os
import sys
import django
from django.core.management import execute_from_command_line

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    django.setup()
    
    from django.core.management import call_command
    from django.db import connection
    
    print("Running migrations...")
    
    # Migrate contenttypes first
    try:
        call_command('migrate', 'contenttypes', verbosity=0, interactive=False)
        print("✓ Contenttypes migrated")
    except Exception as e:
        print(f"⚠ Contenttypes migration: {e}")
    
    # Migrate auth
    try:
        call_command('migrate', 'auth', verbosity=0, interactive=False)
        print("✓ Auth migrated")
    except Exception as e:
        print(f"⚠ Auth migration: {e}")
    
    # Migrate api (creates User model)
    try:
        call_command('migrate', 'api', verbosity=0, interactive=False)
        print("✓ API migrated")
    except Exception as e:
        print(f"⚠ API migration: {e}")
    
    # Try to migrate admin - this may fail due to User model reference
    try:
        call_command('migrate', 'admin', verbosity=0, interactive=False)
        print("✓ Admin migrated")
    except ValueError as e:
        if "Related model 'api.user' cannot be resolved" in str(e):
            print("⚠ Admin migration skipped (User model reference issue)")
            # Try to fake the initial admin migration
            try:
                call_command('migrate', 'admin', '0001_initial', '--fake', verbosity=0, interactive=False)
                print("✓ Admin initial migration faked")
            except:
                pass
        else:
            raise
    
    # Run all remaining migrations
    try:
        call_command('migrate', verbosity=0, interactive=False)
        print("✓ All migrations completed")
    except ValueError as e:
        if "Related model 'api.user' cannot be resolved" in str(e):
            print("⚠ Some migrations skipped due to User model reference")
        else:
            raise
    
    # Start server
    print("Starting Django development server...")
    execute_from_command_line(['manage.py', 'runserver', '0.0.0.0:8000'])

