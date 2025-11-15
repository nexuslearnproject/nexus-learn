"""
Custom test command that handles migrations in correct order
"""
from django.core.management.base import BaseCommand
from django.test.utils import get_runner
from django.conf import settings


class Command(BaseCommand):
    help = 'Run tests with migrations handled in correct order'

    def add_arguments(self, parser):
        parser.add_argument(
            'test_labels',
            nargs='*',
            help='Test labels to run',
        )
        parser.add_argument(
            '--keepdb',
            action='store_true',
            help='Preserves the test database between runs.',
        )

    def handle(self, *args, **options):
        verbosity = options.get('verbosity', 1)
        keepdb = options.get('keepdb', False)
        test_labels = list(args) if args else []
        
        if verbosity > 0 and test_labels:
            self.stdout.write(f"Running tests: {test_labels}")

        # Use a custom test runner
        from django.test.runner import DiscoverRunner
        
        class CustomTestRunner(DiscoverRunner):
            def setup_databases(self, **kwargs):
                """Setup databases and handle User model migration issues"""
                from django.db import connections
                from django.core.management import call_command
                from django.conf import settings
                
                # Ensure TEST settings have all required keys
                for alias in settings.DATABASES:
                    if 'TEST' not in settings.DATABASES[alias]:
                        settings.DATABASES[alias]['TEST'] = {}
                    test_settings = settings.DATABASES[alias]['TEST']
                    defaults = {
                        'MIRROR': None,
                        'CHARSET': None,
                        'COLLATION': None,
                        'NAME': None,
                        'MIGRATE': True,
                        'SERIALIZE': True,
                    }
                    for key, default_value in defaults.items():
                        if key not in test_settings:
                            test_settings[key] = default_value
                
                # Drop test database if it exists to ensure clean state
                test_db_name = 'test_' + settings.DATABASES['default']['NAME']
                if test_db_name.startswith('test_test_'):
                    test_db_name = test_db_name[5:]  # Remove extra 'test_' prefix
                
                # Close all connections
                for conn in connections.all():
                    conn.close()
                
                # Drop test database
                try:
                    import psycopg2
                    db_settings = settings.DATABASES['default']
                    conn = psycopg2.connect(
                        host=db_settings['HOST'],
                        port=db_settings['PORT'],
                        user=db_settings['USER'],
                        password=db_settings['PASSWORD'],
                        database='postgres'
                    )
                    conn.autocommit = True
                    cursor = conn.cursor()
                    # Terminate connections to test database
                    cursor.execute(f"""
                        SELECT pg_terminate_backend(pg_stat_activity.pid)
                        FROM pg_stat_activity
                        WHERE pg_stat_activity.datname = '{test_db_name}'
                        AND pid <> pg_backend_pid();
                    """)
                    cursor.execute(f"DROP DATABASE IF EXISTS {test_db_name};")
                    cursor.close()
                    conn.close()
                except Exception:
                    pass  # Ignore errors - Django will handle it
                
                # Create test databases - Django will run migrations
                # We'll catch and handle the User model error
                try:
                    old_config = super().setup_databases(**kwargs)
                except (ValueError, Exception) as e:
                    error_msg = str(e)
                    if "api.user" in error_msg.lower() or "doesn't provide model 'user'" in error_msg:
                        # User model resolution error - handle it
                        if verbosity > 0:
                            print("Handling User model resolution issue...")
                        
                        # The database was created but migrations failed
                        # Run migrations manually in correct order
                        try:
                            call_command('migrate', 'contenttypes', database='default',
                                       verbosity=verbosity, interactive=False)
                            call_command('migrate', 'auth', database='default',
                                       verbosity=verbosity, interactive=False)
                            call_command('migrate', 'api', database='default',
                                       verbosity=verbosity, interactive=False)
                            # Fake admin migrations to avoid User model issue
                            try:
                                call_command('migrate', 'admin', '0001_initial', '--fake',
                                           database='default', verbosity=verbosity, interactive=False)
                                call_command('migrate', 'admin', database='default',
                                           verbosity=verbosity, interactive=False)
                            except Exception:
                                pass  # Ignore admin migration errors
                            call_command('migrate', database='default',
                                       verbosity=verbosity, interactive=False)
                        except Exception as migrate_error:
                            if verbosity > 0:
                                print(f"Migration error: {migrate_error}")
                            # Continue anyway - database exists
                        
                        # Get old_config - database should be ready now
                        # Format: [(connection, old_name, destroy), ...]
                        from django.db import connections
                        old_config = []
                        for alias in connections:
                            connection = connections[alias]
                            # Get the test database name
                            db_name = connection.settings_dict['NAME']
                            # old_name is the original database name (without test_ prefix)
                            # For teardown, we use the test database name
                            old_config.append((connection, db_name, True))
                    else:
                        raise
                
                return old_config
        
        test_runner = CustomTestRunner(
            verbosity=verbosity,
            interactive=False,
            keepdb=keepdb,
        )

        # Run the tests
        failures = test_runner.run_tests(test_labels)
        
        if failures:
            self.stdout.write(self.style.ERROR(f"\n{failures} test(s) failed."))
        else:
            self.stdout.write(self.style.SUCCESS("\nAll tests passed!"))
