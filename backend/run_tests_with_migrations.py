#!/usr/bin/env python
"""
Test runner that handles migrations in correct order before running tests
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.core.management import call_command, execute_from_command_line
from django.db import connections
from django.test.utils import get_runner
from django.conf import settings

def setup_test_db_with_migrations():
    """Setup test database and run migrations in correct order"""
    from django.db.backends.base.creation import BaseDatabaseCreation
    
    # Get database connection
    connection = connections['default']
    db_name = settings.DATABASES['default']['NAME']
    test_db_name = 'test_' + db_name
    
    # Create test database
    creation = BaseDatabaseCreation(connection)
    
    # Temporarily set test database name
    original_name = connection.settings_dict['NAME']
    connection.settings_dict['NAME'] = test_db_name
    
    try:
        # Drop existing test database if it exists
        try:
            creation._destroy_test_db(test_db_name, verbosity=0)
        except:
            pass
        
        # Create the test database (this also connects to it)
        creation._create_test_db(verbosity=1, autoclobber=True, keepdb=False)
        
        # Close and reconnect to ensure we're using the test database
        connection.close()
        connection.settings_dict['NAME'] = test_db_name
        connection.ensure_connection()
        
        # Run migrations in correct order
        print("Running migrations in correct order...")
        
        # 1. Contenttypes
        call_command('migrate', 'contenttypes', verbosity=1, 
                    interactive=False, database='default')
        
        # 2. Auth
        call_command('migrate', 'auth', verbosity=1, 
                    interactive=False, database='default')
        
        # 3. API (creates User model)
        call_command('migrate', 'api', verbosity=1, 
                    interactive=False, database='default')
        
        # 4. Admin - handle the User model resolution issue
        try:
            call_command('migrate', 'admin', verbosity=1, 
                       interactive=False, database='default')
        except ValueError as e:
            if "Related model 'api.user' cannot be resolved" in str(e):
                print("Faking admin initial migration...")
                # Fake the initial admin migration, then run the rest
                call_command('migrate', 'admin', '0001_initial', '--fake', 
                           verbosity=1, interactive=False, database='default')
                call_command('migrate', 'admin', verbosity=1, 
                           interactive=False, database='default')
            else:
                raise
        
        # 5. All other migrations
        call_command('migrate', verbosity=1, 
                    interactive=False, database='default')
        
        print("Migrations completed successfully!")
        
    except Exception as e:
        # Destroy test database on error
        print(f"Error during migration: {e}")
        import traceback
        traceback.print_exc()
        try:
            creation._destroy_test_db(test_db_name, verbosity=1)
        except:
            pass
        raise
    finally:
        # Restore original name
        connection.settings_dict['NAME'] = original_name
    
    return test_db_name

if __name__ == '__main__':
    # Get test labels from command line
    test_labels = sys.argv[1:] if len(sys.argv) > 1 else None
    
    try:
        # Setup test database with migrations
        test_db_name = setup_test_db_with_migrations()
        
        # Now run the tests using Django's test runner
        # Temporarily set the database name to test database
        connection = connections['default']
        original_name = connection.settings_dict['NAME']
        connection.settings_dict['NAME'] = test_db_name
        
        try:
            # Run tests
            TestRunner = get_runner(settings)
            test_runner = TestRunner(verbosity=1, interactive=False, keepdb=True)
            failures = test_runner.run_tests(test_labels)
        finally:
            # Restore original database name
            connection.settings_dict['NAME'] = original_name
        
        sys.exit(bool(failures))
        
    except Exception as e:
        print(f"Test setup failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

