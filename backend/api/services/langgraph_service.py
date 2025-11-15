"""
LangGraph service wrapper for RAG workflows
"""

import logging
from typing import Dict, Any, Optional, AsyncIterator
from langchain_core.messages import HumanMessage

from .langgraph.graph import create_rag_graph, create_streaming_rag_graph
from .langgraph.state import AgentState

logger = logging.getLogger(__name__)


class LangGraphService:
    """Service for executing LangGraph RAG workflows"""
    
    def __init__(self, enable_checkpoint: bool = False):
        """
        Initialize LangGraph service.
        
        Args:
            enable_checkpoint: Enable state persistence across sessions
        """
        self.enable_checkpoint = enable_checkpoint
        self._graph = None
        self._streaming_graph = None
    
    @property
    def graph(self):
        """Lazy load graph"""
        if self._graph is None:
            self._graph = create_rag_graph(checkpoint=self.enable_checkpoint)
        return self._graph
    
    @property
    def streaming_graph(self):
        """Lazy load streaming graph"""
        if self._streaming_graph is None:
            self._streaming_graph = create_streaming_rag_graph()
        return self._streaming_graph
    
    def answer_question(
        self,
        question: str,
        student_id: str,
        context: Optional[Dict[str, Any]] = None,
        thread_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Answer a question using LangGraph RAG workflow.
        
        Args:
            question: Student's question
            student_id: Student identifier
            context: Additional context (course_id, lesson_id, etc.)
            thread_id: Conversation thread ID for checkpointing
        
        Returns:
            Dictionary with answer, sources, confidence, etc.
        """
        try:
            # Initialize state
            initial_state: AgentState = {
                'question': question,
                'student_id': student_id,
                'context': context or {},
                'messages': [HumanMessage(content=question)],
                'retrieved_docs': [],
                'graph_results': [],
                'weaviate_results': [],
                'context': '',
                'context_sources': [],
                'answer': None,
                'confidence': 0.0,
                'sources': [],
                'next_step': None,
                'question_type': None,
                'retrieval_count': 0,
                'generation_attempts': 0
            }
            
            # Configure input for graph execution
            config = {}
            if thread_id and self.enable_checkpoint:
                config['configurable'] = {'thread_id': thread_id}
            
            # Execute graph
            final_state = self.graph.invoke(initial_state, config=config)
            
            # Format response
            return {
                'answer': final_state.get('answer', ''),
                'sources': final_state.get('sources', []),
                'confidence': final_state.get('confidence', 0.0),
                'question_type': final_state.get('question_type', 'simple'),
                'retrieval_count': final_state.get('retrieval_count', 0),
                'generation_attempts': final_state.get('generation_attempts', 0)
            }
        except Exception as e:
            logger.error(f"Error in LangGraph answer_question: {e}", exc_info=True)
            return {
                'answer': f'ขออภัย เกิดข้อผิดพลาดในการประมวลผล: {str(e)}',
                'sources': [],
                'confidence': 0.0,
                'question_type': 'simple',
                'retrieval_count': 0,
                'generation_attempts': 0
            }
    
    def stream_answer(
        self,
        question: str,
        student_id: str,
        context: Optional[Dict[str, Any]] = None,
        thread_id: Optional[str] = None
    ) -> AsyncIterator[Dict[str, Any]]:
        """
        Stream answer generation in real-time.
        
        Args:
            question: Student's question
            student_id: Student identifier
            context: Additional context
            thread_id: Conversation thread ID
        
        Yields:
            State updates as graph executes
        """
        try:
            # Initialize state
            initial_state: AgentState = {
                'question': question,
                'student_id': student_id,
                'context': context or {},
                'messages': [HumanMessage(content=question)],
                'retrieved_docs': [],
                'graph_results': [],
                'weaviate_results': [],
                'context': '',
                'context_sources': [],
                'answer': None,
                'confidence': 0.0,
                'sources': [],
                'next_step': None,
                'question_type': None,
                'retrieval_count': 0,
                'generation_attempts': 0
            }
            
            # Configure input
            config = {}
            if thread_id and self.enable_checkpoint:
                config['configurable'] = {'thread_id': thread_id}
            
            # Stream execution
            async for event in self.streaming_graph.astream(initial_state, config=config):
                # Yield state updates
                for node_name, node_state in event.items():
                    yield {
                        'node': node_name,
                        'state': {
                            'answer': node_state.get('answer'),
                            'confidence': node_state.get('confidence', 0.0),
                            'retrieval_count': node_state.get('retrieval_count', 0),
                            'sources': node_state.get('sources', [])
                        }
                    }
        except Exception as e:
            logger.error(f"Error in LangGraph stream_answer: {e}", exc_info=True)
            yield {
                'node': 'error',
                'state': {
                    'error': str(e),
                    'answer': None,
                    'confidence': 0.0
                }
            }
    
    def get_conversation_history(
        self,
        thread_id: str,
        limit: int = 10
    ) -> list:
        """
        Get conversation history for a thread (if checkpointing enabled).
        
        Args:
            thread_id: Conversation thread ID
            limit: Maximum number of messages to return
        
        Returns:
            List of conversation messages
        """
        if not self.enable_checkpoint:
            return []
        
        try:
            config = {'configurable': {'thread_id': thread_id}}
            # Get state from checkpoint
            # This would require accessing the graph's checkpointer
            # Implementation depends on checkpoint backend
            return []
        except Exception as e:
            logger.error(f"Error getting conversation history: {e}")
            return []

