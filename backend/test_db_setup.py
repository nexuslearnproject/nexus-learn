"""
Custom test database setup that handles migrations in correct order
"""
from django.test.utils import setup_test_environment, teardown_test_environment
from django.core.management import call_command
from django.db import connections
import sys

def setup_test_db():
    """Setup test database with migrations in correct order"""
    from django.conf import settings
    
    # Setup test environment
    setup_test_environment()
    
    # Get database connection
    db_name = settings.DATABASES['default']['NAME']
    test_db_name = 'test_' + db_name
    
    # Create test database
    connection = connections['default']
    connection.settings_dict['NAME'] = test_db_name
    
    # Create the test database
    from django.db.backends.base.creation import BaseDatabaseCreation
    creation = BaseDatabaseCreation(connection)
    creation._create_test_db(verbosity=1, autoclobber=True, keepdb=False)
    
    # Run migrations in correct order
    try:
        # 1. Contenttypes (needed for all models)
        call_command('migrate', 'contenttypes', verbosity=0, 
                    interactive=False, database='default')
        
        # 2. Auth (needed before User model)
        call_command('migrate', 'auth', verbosity=0, 
                    interactive=False, database='default')
        
        # 3. API (creates User model)
        call_command('migrate', 'api', verbosity=0, 
                    interactive=False, database='default')
        
        # 4. Admin (may fail, but we'll handle it)
        try:
            call_command('migrate', 'admin', verbosity=0, 
                        interactive=False, database='default')
        except ValueError as e:
            if "Related model 'api.user' cannot be resolved" in str(e):
                # Fake the admin migrations since User model exists now
                call_command('migrate', 'admin', '0001_initial', '--fake', 
                           verbosity=0, interactive=False, database='default')
                call_command('migrate', 'admin', verbosity=0, 
                           interactive=False, database='default')
            else:
                raise
        
        # 5. All other migrations
        call_command('migrate', verbosity=0, 
                    interactive=False, database='default')
        
    except Exception as e:
        print(f"Migration error: {e}")
        # Destroy test database on error
        creation._destroy_test_db(test_db_name, verbosity=1)
        raise
    
    return test_db_name

def teardown_test_db(test_db_name):
    """Teardown test database"""
    from django.db import connections
    from django.db.backends.base.creation import BaseDatabaseCreation
    
    connection = connections['default']
    creation = BaseDatabaseCreation(connection)
    creation._destroy_test_db(test_db_name, verbosity=1)
    teardown_test_environment()

