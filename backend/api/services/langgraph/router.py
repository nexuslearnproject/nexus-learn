"""
Router node for classifying questions and routing to appropriate workflow
"""

import logging
from typing import Dict, Any
import re

from .state import AgentState

logger = logging.getLogger(__name__)


def router_node(state: AgentState) -> Dict[str, Any]:
    """
    Classify question complexity and route to appropriate workflow.
    
    Returns:
        - question_type: 'simple', 'complex', or 'multi_hop'
        - next_step: next node to execute
    """
    try:
        question = state.get('question', '').lower()
        context = state.get('context', {})
        
        # Rule-based classification (can be enhanced with LLM)
        question_type = classify_question(question, context)
        
        # Determine next step based on question type
        if question_type == 'simple':
            next_step = 'simple_rag'
        elif question_type == 'complex':
            next_step = 'complex_rag'
        else:  # multi_hop
            next_step = 'multi_hop_rag'
        
        logger.info(f"Question classified as: {question_type}, routing to: {next_step}")
        
        return {
            'question_type': question_type,
            'next_step': next_step
        }
    except Exception as e:
        logger.error(f"Error in router_node: {e}")
        # Default to simple RAG
        return {
            'question_type': 'simple',
            'next_step': 'simple_rag'
        }


def classify_question(question: str, context: Dict[str, Any] = None) -> str:
    """
    Classify question complexity.
    
    Returns:
        - 'simple': Direct answer from single retrieval
        - 'complex': Multi-step retrieval + reasoning
        - 'multi_hop': Requires follow-up questions or concept expansion
    """
    question_lower = question.lower()
    
    # Multi-hop indicators
    multi_hop_keywords = [
        'prerequisite', 'prerequisites', 'before', 'after', 'next',
        'related to', 'similar to', 'compare', 'difference between',
        'how to', 'step by step', 'process', 'workflow'
    ]
    
    # Complex indicators
    complex_keywords = [
        'why', 'explain', 'describe', 'analyze', 'evaluate',
        'what are', 'what is', 'how does', 'what causes',
        'advantages', 'disadvantages', 'pros and cons'
    ]
    
    # Check for multi-hop patterns
    if any(keyword in question_lower for keyword in multi_hop_keywords):
        return 'multi_hop'
    
    # Check for complex patterns
    if any(keyword in question_lower for keyword in complex_keywords):
        return 'complex'
    
    # Check question length (longer questions tend to be more complex)
    if len(question.split()) > 15:
        return 'complex'
    
    # Check for multiple question marks or conjunctions
    if question.count('?') > 1 or ' and ' in question_lower or ' or ' in question_lower:
        return 'complex'
    
    # Default to simple
    return 'simple'


def llm_classify_question(question: str, llm=None) -> str:
    """
    Use LLM to classify question (optional enhancement).
    
    This can be used instead of rule-based classification for better accuracy.
    """
    try:
        if llm is None:
            from langchain_openai import ChatOpenAI
            import os
            
            llm = ChatOpenAI(
                model=os.getenv('LANGGRAPH_LLM_MODEL', 'gpt-4o-mini'),
                temperature=0.0
            )
        
        prompt = f"""Classify this question into one of three categories:
- simple: Can be answered with a direct fact or definition
- complex: Requires explanation or analysis
- multi_hop: Requires multiple steps, prerequisites, or related concepts

Question: {question}

Respond with only one word: simple, complex, or multi_hop"""
        
        response = llm.invoke(prompt)
        classification = response.content.strip().lower() if hasattr(response, 'content') else str(response).strip().lower()
        
        if classification in ['simple', 'complex', 'multi_hop']:
            return classification
        
        return 'simple'  # Default fallback
    except Exception as e:
        logger.warning(f"LLM classification failed: {e}, using rule-based")
        return classify_question(question)

