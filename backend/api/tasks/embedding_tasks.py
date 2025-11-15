"""
Celery tasks for batch embedding processing
"""

from celery import shared_task
import logging
from typing import List, Dict, Any

logger = logging.getLogger(__name__)


@shared_task(bind=True, name='api.tasks.embeddings.process_batch')
def process_embeddings_batch(
    self,
    texts: List[str],
    metadata: List[Dict[str, Any]] = None
) -> List[List[float]]:
    """
    Process batch of texts to generate embeddings asynchronously.
    
    Args:
        texts: List of texts to embed
        metadata: Optional metadata for each text
    
    Returns:
        List of embedding vectors
    """
    try:
        self.update_state(
            state='PROCESSING',
            meta={'step': 'Loading embedding model', 'progress': 0}
        )
        
        from api.services.vector_service import VectorStoreService
        
        vector_service = VectorStoreService()
        vector_service.load_model()
        
        total = len(texts)
        embeddings = []
        
        for i, text in enumerate(texts):
            embedding = vector_service.generate_embedding(text)
            embeddings.append(embedding)
            
            # Update progress
            progress = int((i + 1) / total * 100)
            self.update_state(
                state='PROCESSING',
                meta={
                    'step': f'Processing text {i+1}/{total}',
                    'progress': progress
                }
            )
        
        self.update_state(
            state='SUCCESS',
            meta={
                'step': 'Completed',
                'total': total
            }
        )
        
        return embeddings
        
    except Exception as e:
        logger.error(f"Error processing embeddings batch: {e}", exc_info=True)
        self.update_state(
            state='FAILURE',
            meta={
                'error': str(e),
                'step': 'Failed'
            }
        )
        raise

