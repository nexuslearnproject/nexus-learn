"""
Celery tasks for LangGraph async processing
"""

from celery import shared_task
from celery.result import AsyncResult
import logging
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)


@shared_task(bind=True, name='api.tasks.langgraph.process_question')
def process_langgraph_question(
    self,
    question: str,
    student_id: str,
    context: Optional[Dict[str, Any]] = None,
    thread_id: Optional[str] = None
) -> Dict[str, Any]:
    """
    Process LangGraph question asynchronously.
    
    Args:
        question: Student's question
        student_id: Student identifier
        context: Additional context (course_id, lesson_id, etc.)
        thread_id: Conversation thread ID for checkpointing
    
    Returns:
        Dictionary with answer, sources, confidence, etc.
    """
    try:
        # Update task state
        self.update_state(
            state='PROCESSING',
            meta={'step': 'Initializing LangGraph workflow'}
        )
        
        # Import here to avoid circular imports
        from api.services.langgraph_service import LangGraphService
        import os
        
        enable_checkpoint = os.getenv('LANGGRAPH_PERSIST', 'False').lower() == 'true'
        langgraph_service = LangGraphService(enable_checkpoint=enable_checkpoint)
        
        # Update state
        self.update_state(
            state='PROCESSING',
            meta={'step': 'Executing LangGraph workflow'}
        )
        
        # Execute LangGraph workflow
        result = langgraph_service.answer_question(
            question=question,
            student_id=student_id,
            context=context,
            thread_id=thread_id
        )
        
        # Update state
        self.update_state(
            state='SUCCESS',
            meta={
                'step': 'Completed',
                'result': result
            }
        )
        
        return result
        
    except Exception as e:
        logger.error(f"Error processing LangGraph question: {e}", exc_info=True)
        self.update_state(
            state='FAILURE',
            meta={
                'error': str(e),
                'step': 'Failed'
            }
        )
        raise


@shared_task(name='api.tasks.langgraph.get_status')
def get_task_status(task_id: str) -> Dict[str, Any]:
    """
    Get status of a Celery task.
    
    Args:
        task_id: Celery task ID
    
    Returns:
        Task status and result if available
    """
    task_result = AsyncResult(task_id)
    
    response = {
        'task_id': task_id,
        'status': task_result.status,
        'ready': task_result.ready(),
    }
    
    if task_result.ready():
        if task_result.successful():
            response['result'] = task_result.result
        else:
            response['error'] = str(task_result.info)
    else:
        # Get progress info
        if task_result.info:
            response['info'] = task_result.info
    
    return response

