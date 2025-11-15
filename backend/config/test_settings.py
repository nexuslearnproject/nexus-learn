"""
Test settings that handle migrations properly for custom User model
"""
from .settings import *

# Override database name for tests  
DATABASES['default']['NAME'] = TEST_DATABASE_NAME

# Custom database creation class that handles migrations in correct order
from django.db.backends.postgresql.creation import DatabaseCreation

class CustomDatabaseCreation(DatabaseCreation):
    """Custom database creation that handles migrations in correct order"""
    
    def _create_test_db(self, verbosity, autoclobber, keepdb=False, serialize=True):
        """Create test database and run migrations in correct order"""
        from django.core.management import call_command
        
        # Create the test database first
        test_db_name = super()._create_test_db(verbosity, autoclobber, keepdb, serialize)
        
        # Now run migrations in correct order
        try:
            # 1. Contenttypes
            call_command('migrate', 'contenttypes', verbosity=verbosity, 
                        interactive=False, database='default')
            
            # 2. Auth
            call_command('migrate', 'auth', verbosity=verbosity, 
                        interactive=False, database='default')
            
            # 3. API (creates User model)
            call_command('migrate', 'api', verbosity=verbosity, 
                        interactive=False, database='default')
            
            # 4. Admin - handle the User model resolution issue
            try:
                call_command('migrate', 'admin', verbosity=verbosity, 
                           interactive=False, database='default')
            except ValueError as e:
                if "Related model 'api.user' cannot be resolved" in str(e):
                    # Fake the initial admin migration, then run the rest
                    call_command('migrate', 'admin', '0001_initial', '--fake', 
                               verbosity=verbosity, interactive=False, database='default')
                    call_command('migrate', 'admin', verbosity=verbosity, 
                               interactive=False, database='default')
                else:
                    raise
            
            # 5. All other migrations
            call_command('migrate', verbosity=verbosity, 
                        interactive=False, database='default')
        except Exception as e:
            # If migrations fail, destroy the test database
            self._destroy_test_db(test_db_name, verbosity)
            raise
        
        return test_db_name

# Override the database creation class
DATABASES['default']['TEST'] = {
    'CREATE_DB': True,
    'NAME': TEST_DATABASE_NAME,
}

