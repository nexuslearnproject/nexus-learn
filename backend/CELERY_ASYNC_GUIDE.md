# Celery Async Processing Guide

This guide explains how to use Celery for async processing of LangGraph workloads.

## Overview

Celery has been integrated to handle heavy AI workloads asynchronously, preventing blocking of API requests during LangGraph processing.

## Architecture

```
API Request → Queue Task → Return Task ID → Poll Status
                ↓
            Celery Worker
                ↓
        LangGraph Processing
                ↓
        Store Result (Redis)
```

## Setup

### 1. Start Services

```bash
docker-compose up -d redis celery_worker celery_beat
```

Or start all services:

```bash
docker-compose up -d
```

### 2. Verify Celery Worker

```bash
docker-compose logs celery_worker
```

You should see:
```
celery@... ready.
```

### 3. Monitor Tasks

```bash
python manage.py celery_monitor --active --stats
```

## Usage

### Submit Async Task

**Endpoint:** `POST /api/ai/ask-async/`

```bash
curl -X POST http://localhost:8000/api/ai/ask-async/ \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "student_123",
    "question": "What is Python?",
    "context": {"course_id": "python_101"},
    "thread_id": "conversation_123"
  }'
```

**Response:**
```json
{
  "task_id": "abc123-def456-...",
  "status": "PENDING",
  "message": "Question submitted for processing"
}
```

### Check Task Status

**Endpoint:** `GET /api/ai/tasks/<task_id>/status/`

```bash
curl http://localhost:8000/api/ai/tasks/abc123-def456-.../status/
```

**Response (Processing):**
```json
{
  "task_id": "abc123-def456-...",
  "status": "PROCESSING",
  "ready": false,
  "info": {
    "step": "Executing LangGraph workflow"
  }
}
```

**Response (Completed):**
```json
{
  "task_id": "abc123-def456-...",
  "status": "SUCCESS",
  "ready": true,
  "result": {
    "answer": "...",
    "sources": [...],
    "confidence": 0.92,
    "question_type": "complex"
  }
}
```

**Response (Failed):**
```json
{
  "task_id": "abc123-def456-...",
  "status": "FAILURE",
  "ready": true,
  "error": "Error message here"
}
```

## Task Status Values

- **PENDING**: Task is waiting to be processed
- **PROCESSING**: Task is being executed
- **SUCCESS**: Task completed successfully
- **FAILURE**: Task failed with an error
- **REVOKED**: Task was cancelled

## Frontend Integration Example

```javascript
// Submit async question
async function askQuestionAsync(question, studentId) {
  const response = await fetch('http://localhost:8000/api/ai/ask-async/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      student_id: studentId,
      question: question
    })
  });
  
  const data = await response.json();
  return data.task_id;
}

// Poll for result
async function pollTaskStatus(taskId) {
  const maxAttempts = 60; // 60 seconds max
  let attempts = 0;
  
  while (attempts < maxAttempts) {
    const response = await fetch(
      `http://localhost:8000/api/ai/tasks/${taskId}/status/`
    );
    const status = await response.json();
    
    if (status.ready) {
      if (status.status === 'SUCCESS') {
        return status.result;
      } else {
        throw new Error(status.error || 'Task failed');
      }
    }
    
    // Wait 1 second before next poll
    await new Promise(resolve => setTimeout(resolve, 1000));
    attempts++;
  }
  
  throw new Error('Task timeout');
}

// Usage
const taskId = await askQuestionAsync("What is Python?", "student_123");
const result = await pollTaskStatus(taskId);
console.log(result.answer);
```

## Monitoring

### View Active Tasks

```bash
python manage.py celery_monitor --active
```

### View Worker Statistics

```bash
python manage.py celery_monitor --stats
```

### View Scheduled Tasks

```bash
python manage.py celery_monitor --scheduled
```

### Using Celery CLI

```bash
# Inspect active tasks
docker-compose exec celery_worker celery -A config.celery inspect active

# View worker stats
docker-compose exec celery_worker celery -A config.celery inspect stats

# Purge all tasks
docker-compose exec celery_worker celery -A config.celery purge
```

## Configuration

### Environment Variables

Add to `.env`:

```env
# Celery Configuration
CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0
REDIS_HOST=redis
REDIS_PORT=6379
```

### Task Queues

Tasks are routed to specific queues:

- **langgraph**: LangGraph processing tasks
- **embeddings**: Batch embedding generation tasks

### Scaling Workers

To scale workers:

```bash
# Scale langgraph queue workers
docker-compose up -d --scale celery_worker=3
```

Or update `docker-compose.yml`:

```yaml
celery_worker:
  deploy:
    replicas: 3
```

## Performance Tips

1. **Polling Interval**: Poll every 1-2 seconds for better UX
2. **Timeout**: Set reasonable timeout (60-120 seconds)
3. **Queue Priority**: Use different queues for different priorities
4. **Worker Concurrency**: Adjust `--concurrency` based on CPU/memory
5. **Result Expiration**: Results expire after 1 hour (configurable)

## Troubleshooting

### Worker Not Starting

```bash
# Check logs
docker-compose logs celery_worker

# Verify Redis connection
docker-compose exec celery_worker celery -A config.celery inspect ping
```

### Tasks Stuck in PENDING

1. Check if workers are running: `docker-compose ps celery_worker`
2. Check worker logs: `docker-compose logs celery_worker`
3. Verify Redis is accessible: `docker-compose exec redis redis-cli ping`

### Tasks Failing

1. Check task logs: `docker-compose logs celery_worker`
2. Check task status via API
3. Verify dependencies (Neo4j, Weaviate, LLM API keys)

### Memory Issues

Reduce worker concurrency:

```yaml
command: celery -A config.celery worker --loglevel=info --queues=langgraph,embeddings --concurrency=1
```

## Comparison: Sync vs Async

### Synchronous (Blocking)
```python
# Blocks until complete (30-60 seconds)
result = ai_agent.answer_with_langgraph(...)
return result
```

### Asynchronous (Non-blocking)
```python
# Returns immediately
task = process_langgraph_question.delay(...)
return {'task_id': task.id}

# Poll for result later
status = get_task_status(task.id)
```

## Benefits

1. **Non-blocking API**: Requests return immediately
2. **Better UX**: Show progress indicators
3. **Scalability**: Workers scale independently
4. **Resilience**: Tasks retry on failure
5. **Resource Isolation**: AI workloads don't block API

## Next Steps

1. Add WebSocket support for real-time updates
2. Implement task prioritization
3. Add rate limiting per user
4. Set up monitoring dashboard (Flower)
5. Add task result caching

