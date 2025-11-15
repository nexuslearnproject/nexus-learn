"""
State management for LangGraph agent workflows
"""

from typing import TypedDict, List, Dict, Any, Optional, Annotated
from langchain_core.messages import BaseMessage
from operator import add


class AgentState(TypedDict):
    """State structure for LangGraph RAG workflow"""
    
    # Input
    question: str
    student_id: str
    context: Optional[Dict[str, Any]]  # Additional context (course_id, lesson_id, etc.)
    
    # Messages (for conversation history)
    messages: Annotated[List[BaseMessage], add]
    
    # Retrieval results
    retrieved_docs: List[Dict[str, Any]]  # Documents from vector search
    graph_results: List[Dict[str, Any]]  # Results from Neo4j graph traversal
    weaviate_results: List[Dict[str, Any]]  # Results from Weaviate (if used)
    
    # Context building
    context: str  # Combined context for LLM
    context_sources: List[Dict[str, Any]]  # Source metadata for context
    
    # Generation
    answer: Optional[str]
    confidence: float
    
    # Output
    sources: List[Dict[str, Any]]  # Formatted sources for response
    next_step: Optional[str]  # For routing decisions
    
    # Metadata
    question_type: Optional[str]  # simple, complex, multi_hop
    retrieval_count: int  # Number of retrieval steps performed
    generation_attempts: int  # Number of generation attempts

