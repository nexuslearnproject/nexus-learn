#!/usr/bin/env python
"""
Test runner script that handles migrations in correct order
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.core.management import call_command
from django.test.utils import get_runner
from django.conf import settings

def run_tests():
    """Run tests with proper migration handling"""
    # Get test labels from command line args
    test_labels = sys.argv[1:] if len(sys.argv) > 1 else None
    
    # Get the test runner
    TestRunner = get_runner(settings)
    test_runner = TestRunner(verbosity=1, interactive=False, keepdb=False)
    
    # Setup test databases with custom migration order
    old_config = test_runner.setup_databases()
    
    try:
        # Run the tests
        failures = test_runner.run_tests(test_labels)
    finally:
        # Teardown test databases
        test_runner.teardown_databases(old_config)
    
    return failures

if __name__ == '__main__':
    failures = run_tests()
    sys.exit(bool(failures))

