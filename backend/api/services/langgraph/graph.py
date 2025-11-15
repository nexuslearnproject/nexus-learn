"""
LangGraph workflow definition for RAG
"""

import logging
from typing import Literal

from langgraph.graph import StateGraph, END
from langgraph.checkpoint.memory import MemorySaver

from .state import AgentState
from .nodes import (
    retrieve_node,
    graph_retrieve_node,
    weaviate_retrieve_node,
    combine_context_node,
    generate_node,
    validate_node,
    store_interaction_node
)
from .router import router_node

logger = logging.getLogger(__name__)


def should_continue(state: AgentState) -> Literal["simple_rag", "complex_rag", "multi_hop_rag"]:
    """Determine which workflow to follow based on router decision"""
    next_step = state.get('next_step', 'simple_rag')
    
    if next_step == 'complex_rag':
        return "complex_rag"
    elif next_step == 'multi_hop_rag':
        return "multi_hop_rag"
    else:
        return "simple_rag"


def simple_rag_chain(state: AgentState) -> AgentState:
    """Simple RAG workflow: retrieve → combine → generate → validate → store"""
    # Retrieve
    state = {**state, **retrieve_node(state)}
    
    # Combine context
    state = {**state, **combine_context_node(state)}
    
    # Generate
    state = {**state, **generate_node(state)}
    
    # Validate
    state = {**state, **validate_node(state)}
    
    # Store
    state = {**state, **store_interaction_node(state)}
    
    return state


def complex_rag_chain(state: AgentState) -> AgentState:
    """Complex RAG workflow: retrieve → graph retrieve → combine → generate → validate → store"""
    # Retrieve
    state = {**state, **retrieve_node(state)}
    
    # Graph retrieve (get related concepts)
    state = {**state, **graph_retrieve_node(state)}
    
    # Combine context
    state = {**state, **combine_context_node(state)}
    
    # Generate
    state = {**state, **generate_node(state)}
    
    # Validate
    state = {**state, **validate_node(state)}
    
    # Store
    state = {**state, **store_interaction_node(state)}
    
    return state


def multi_hop_rag_chain(state: AgentState) -> AgentState:
    """Multi-hop RAG workflow: retrieve → graph retrieve → weaviate → combine → generate → validate → store"""
    # Retrieve
    state = {**state, **retrieve_node(state)}
    
    # Graph retrieve (expand concepts)
    state = {**state, **graph_retrieve_node(state)}
    
    # Weaviate retrieve (if available)
    try:
        state = {**state, **weaviate_retrieve_node(state)}
    except Exception as e:
        logger.warning(f"Weaviate retrieval skipped: {e}")
    
    # Combine context
    state = {**state, **combine_context_node(state)}
    
    # Generate
    state = {**state, **generate_node(state)}
    
    # Validate
    state = {**state, **validate_node(state)}
    
    # Store
    state = {**state, **store_interaction_node(state)}
    
    return state


def create_rag_graph(checkpoint: bool = False):
    """
    Create and compile LangGraph workflow for RAG.
    
    Args:
        checkpoint: Whether to enable checkpointing for state persistence
    
    Returns:
        Compiled LangGraph workflow
    """
    # Create graph
    workflow = StateGraph(AgentState)
    
    # Add nodes
    workflow.add_node("router", router_node)
    workflow.add_node("simple_rag", simple_rag_chain)
    workflow.add_node("complex_rag", complex_rag_chain)
    workflow.add_node("multi_hop_rag", multi_hop_rag_chain)
    
    # Set entry point
    workflow.set_entry_point("router")
    
    # Add conditional edges from router
    workflow.add_conditional_edges(
        "router",
        should_continue,
        {
            "simple_rag": "simple_rag",
            "complex_rag": "complex_rag",
            "multi_hop_rag": "multi_hop_rag"
        }
    )
    
    # All workflows end after completion
    workflow.add_edge("simple_rag", END)
    workflow.add_edge("complex_rag", END)
    workflow.add_edge("multi_hop_rag", END)
    
    # Compile graph
    if checkpoint:
        memory = MemorySaver()
        app = workflow.compile(checkpointer=memory)
    else:
        app = workflow.compile()
    
    logger.info("LangGraph RAG workflow compiled successfully")
    
    return app


def create_streaming_rag_graph():
    """Create streaming version of RAG graph (for real-time responses)"""
    graph = create_rag_graph(checkpoint=False)
    return graph

