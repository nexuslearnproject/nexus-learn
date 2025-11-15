"""
Celery configuration for async task processing
"""

import os
from celery import Celery
from django.conf import settings

# Set default Django settings module
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

app = Celery('nexus_learn')

# Load configuration from Django settings
app.config_from_object('django.conf:settings', namespace='CELERY')

# Auto-discover tasks from all installed apps
app.autodiscover_tasks()

# Task routing configuration
app.conf.task_routes = {
    'api.tasks.langgraph.*': {'queue': 'langgraph'},
    'api.tasks.embeddings.*': {'queue': 'embeddings'},
}

# Serialization settings
app.conf.task_serializer = 'json'
app.conf.accept_content = ['json']
app.conf.result_serializer = 'json'
app.conf.timezone = 'UTC'
app.conf.enable_utc = True

# Result backend
redis_host = os.getenv('REDIS_HOST', 'redis')
redis_port = os.getenv('REDIS_PORT', '6379')
app.conf.result_backend = f"redis://{redis_host}:{redis_port}/0"

# Task time limits
app.conf.task_time_limit = 300  # 5 minutes hard limit
app.conf.task_soft_time_limit = 240  # 4 minutes soft limit

# Worker settings
app.conf.worker_prefetch_multiplier = 1  # Disable prefetching for better load balancing
app.conf.worker_max_tasks_per_child = 50  # Restart worker after 50 tasks to prevent memory leaks

# Task result expiration
app.conf.result_expires = 3600  # 1 hour

# Task tracking
app.conf.task_track_started = True
app.conf.task_send_sent_event = True

@app.task(bind=True)
def debug_task(self):
    """Debug task for testing Celery setup"""
    print(f'Request: {self.request!r}')

