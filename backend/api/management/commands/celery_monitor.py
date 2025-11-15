"""
Django management command to monitor Celery tasks
"""

from django.core.management.base import BaseCommand
from celery import current_app


class Command(BaseCommand):
    help = 'Monitor Celery tasks and workers'

    def add_arguments(self, parser):
        parser.add_argument(
            '--active',
            action='store_true',
            help='Show active tasks',
        )
        parser.add_argument(
            '--scheduled',
            action='store_true',
            help='Show scheduled tasks',
        )
        parser.add_argument(
            '--stats',
            action='store_true',
            help='Show worker statistics',
        )

    def handle(self, *args, **options):
        inspect = current_app.control.inspect()
        
        if options['active']:
            self.stdout.write(self.style.SUCCESS('Active Tasks:'))
            active = inspect.active()
            if active:
                for worker, tasks in active.items():
                    self.stdout.write(f"\nWorker: {worker}")
                    for task in tasks:
                        self.stdout.write(f"  - {task['name']} (ID: {task['id']})")
            else:
                self.stdout.write('  No active tasks')
        
        if options['scheduled']:
            self.stdout.write(self.style.SUCCESS('\nScheduled Tasks:'))
            scheduled = inspect.scheduled()
            if scheduled:
                for worker, tasks in scheduled.items():
                    self.stdout.write(f"\nWorker: {worker}")
                    for task in tasks:
                        self.stdout.write(f"  - {task['request']['name']} (ID: {task['request']['id']})")
            else:
                self.stdout.write('  No scheduled tasks')
        
        if options['stats']:
            self.stdout.write(self.style.SUCCESS('\nWorker Statistics:'))
            stats = inspect.stats()
            if stats:
                for worker, stat in stats.items():
                    self.stdout.write(f"\nWorker: {worker}")
                    self.stdout.write(f"  Status: {stat.get('status', 'unknown')}")
                    self.stdout.write(f"  Pool: {stat.get('pool', {}).get('implementation', 'unknown')}")
                    self.stdout.write(f"  Processes: {stat.get('pool', {}).get('processes', [])}")
                    self.stdout.write(f"  Total tasks: {stat.get('total', {}).get('tasks', {}).get('total', 0)}")
            else:
                self.stdout.write('  No workers available')
        
        if not any([options['active'], options['scheduled'], options['stats']]):
            # Show all by default
            self.stdout.write(self.style.SUCCESS('Celery Monitor'))
            self.stdout.write('Use --active, --scheduled, or --stats to view specific information')
            self.stdout.write('Or use --help for more options')

