"""
LangGraph node implementations for RAG workflow
"""

import logging
from typing import Dict, Any, List
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage

from .state import AgentState

logger = logging.getLogger(__name__)


def retrieve_node(state: AgentState) -> Dict[str, Any]:
    """Retrieve relevant documents using semantic search"""
    try:
        from ..vector_service import VectorStoreService
        
        vector_service = VectorStoreService()
        question = state.get('question', '')
        
        # Perform semantic search
        results = vector_service.semantic_search(
            query=question,
            node_label="Knowledge",
            limit=5,
            threshold=0.7
        )
        
        logger.info(f"Retrieved {len(results)} documents for question: {question[:50]}")
        
        return {
            'retrieved_docs': results,
            'retrieval_count': state.get('retrieval_count', 0) + 1
        }
    except Exception as e:
        logger.error(f"Error in retrieve_node: {e}")
        return {
            'retrieved_docs': [],
            'retrieval_count': state.get('retrieval_count', 0) + 1
        }


def graph_retrieve_node(state: AgentState) -> Dict[str, Any]:
    """Retrieve related concepts from Neo4j graph"""
    try:
        from ..neo4j_service import Neo4jService
        
        neo4j_service = Neo4jService()
        question = state.get('question', '')
        retrieved_docs = state.get('retrieved_docs', [])
        
        graph_results = []
        
        # Extract concept IDs from retrieved documents
        concept_ids = []
        for doc in retrieved_docs[:3]:  # Top 3 documents
            node = doc.get('node', {})
            if isinstance(node, dict):
                node_id = node.get('id')
                if node_id:
                    concept_ids.append(node_id)
        
        # Get related concepts from graph
        for concept_id in concept_ids:
            related = neo4j_service.get_related_concepts(
                concept_id=concept_id,
                relationship_types=['RELATED_TO', 'PREREQUISITE', 'SIMILAR_TO'],
                depth=1
            )
            graph_results.extend(related)
        
        logger.info(f"Retrieved {len(graph_results)} related concepts from graph")
        
        return {
            'graph_results': graph_results
        }
    except Exception as e:
        logger.error(f"Error in graph_retrieve_node: {e}")
        return {
            'graph_results': []
        }


def weaviate_retrieve_node(state: AgentState) -> Dict[str, Any]:
    """Retrieve documents from Weaviate (if configured separately)"""
    try:
        import weaviate
        import os
        
        weaviate_url = os.getenv('WEAVIATE_URL', 'http://weaviate:8080')
        question = state.get('question', '')
        
        # Connect to Weaviate
        client = weaviate.Client(weaviate_url)
        
        # Perform vector search
        query_result = (
            client.query
            .get("Document", ["content", "title", "metadata"])
            .with_near_text({"concepts": [question]})
            .with_limit(5)
            .do()
        )
        
        results = []
        if 'data' in query_result and 'Get' in query_result['data']:
            for item in query_result['data']['Get'].get('Document', []):
                results.append({
                    'content': item.get('content', ''),
                    'title': item.get('title', ''),
                    'metadata': item.get('metadata', {})
                })
        
        logger.info(f"Retrieved {len(results)} documents from Weaviate")
        
        return {
            'weaviate_results': results
        }
    except Exception as e:
        logger.warning(f"Weaviate retrieval not available: {e}")
        return {
            'weaviate_results': []
        }


def combine_context_node(state: AgentState) -> Dict[str, Any]:
    """Combine retrieval results into context string"""
    try:
        retrieved_docs = state.get('retrieved_docs', [])
        graph_results = state.get('graph_results', [])
        weaviate_results = state.get('weaviate_results', [])
        
        context_parts = []
        sources = []
        
        # Add retrieved documents
        for doc in retrieved_docs:
            node = doc.get('node', {})
            if isinstance(node, dict):
                content = node.get('content', node.get('text', ''))
                if content:
                    context_parts.append(content)
                    sources.append({
                        'id': node.get('id'),
                        'title': node.get('title', content[:100]),
                        'score': doc.get('score', 0.0),
                        'type': 'vector_search'
                    })
        
        # Add graph results
        for result in graph_results[:5]:  # Top 5 graph results
            related = result.get('related', {})
            if isinstance(related, dict):
                content = related.get('content', related.get('text', ''))
                if content and content not in context_parts:
                    context_parts.append(content)
                    sources.append({
                        'id': related.get('id'),
                        'title': related.get('title', content[:100]),
                        'type': 'graph_traversal'
                    })
        
        # Add Weaviate results
        for result in weaviate_results:
            content = result.get('content', '')
            if content and content not in context_parts:
                context_parts.append(content)
                sources.append({
                    'id': result.get('id'),
                    'title': result.get('title', content[:100]),
                    'type': 'weaviate_search'
                })
        
        # Combine context
        context = "\n\n".join(context_parts[:10])  # Limit to top 10 chunks
        
        logger.info(f"Combined context: {len(context)} characters from {len(sources)} sources")
        
        return {
            'context': context,
            'context_sources': sources[:10]  # Top 10 sources
        }
    except Exception as e:
        logger.error(f"Error in combine_context_node: {e}")
        return {
            'context': '',
            'context_sources': []
        }


def generate_node(state: AgentState) -> Dict[str, Any]:
    """Generate answer using LLM"""
    try:
        from langchain_openai import ChatOpenAI
        from langchain_anthropic import ChatAnthropic
        import os
        
        question = state.get('question', '')
        context = state.get('context', '')
        student_id = state.get('student_id', '')
        messages = state.get('messages', [])
        
        # Initialize LLM
        llm_provider = os.getenv('LANGGRAPH_LLM_PROVIDER', 'openai').lower()
        llm_model = os.getenv('LANGGRAPH_LLM_MODEL', 'gpt-4o-mini')
        
        if llm_provider == 'anthropic':
            llm = ChatAnthropic(
                model=llm_model,
                temperature=0.7,
                api_key=os.getenv('ANTHROPIC_API_KEY')
            )
        else:
            llm = ChatOpenAI(
                model=llm_model,
                temperature=0.7,
                api_key=os.getenv('OPENAI_API_KEY')
            )
        
        # Build prompt
        system_prompt = """You are an AI tutor helping students learn. 
        Use the provided context to answer questions accurately and helpfully.
        If the context doesn't contain enough information, say so clearly.
        Provide clear, educational explanations."""
        
        prompt = f"""Context:
{context}

Question: {question}

Please provide a helpful answer based on the context above."""
        
        # Prepare messages
        llm_messages = [SystemMessage(content=system_prompt)]
        llm_messages.extend(messages[-5:])  # Last 5 messages for context
        llm_messages.append(HumanMessage(content=prompt))
        
        # Generate response
        response = llm.invoke(llm_messages)
        answer = response.content if hasattr(response, 'content') else str(response)
        
        logger.info(f"Generated answer: {len(answer)} characters")
        
        return {
            'answer': answer,
            'messages': messages + [HumanMessage(content=question), AIMessage(content=answer)],
            'generation_attempts': state.get('generation_attempts', 0) + 1
        }
    except Exception as e:
        logger.error(f"Error in generate_node: {e}")
        # Fallback answer
        return {
            'answer': f"ขออภัย เกิดข้อผิดพลาดในการสร้างคำตอบ: {str(e)}",
            'generation_attempts': state.get('generation_attempts', 0) + 1
        }


def validate_node(state: AgentState) -> Dict[str, Any]:
    """Validate answer quality and calculate confidence"""
    try:
        answer = state.get('answer', '')
        context = state.get('context', '')
        retrieved_docs = state.get('retrieved_docs', [])
        context_sources = state.get('context_sources', [])
        
        # Calculate confidence based on:
        # 1. Answer length (not too short, not too long)
        # 2. Context availability
        # 3. Source scores
        
        confidence = 0.5  # Base confidence
        
        # Check answer quality
        if answer and len(answer) > 50:
            confidence += 0.2
        if answer and len(answer) < 5000:  # Not too long
            confidence += 0.1
        
        # Check context availability
        if context and len(context) > 100:
            confidence += 0.1
        
        # Check source scores
        if retrieved_docs:
            avg_score = sum(doc.get('score', 0.0) for doc in retrieved_docs) / len(retrieved_docs)
            confidence += min(avg_score * 0.2, 0.2)
        
        # Check number of sources
        if len(context_sources) >= 3:
            confidence += 0.1
        
        confidence = min(confidence, 1.0)
        
        logger.info(f"Answer validation: confidence={confidence:.2f}")
        
        # Format sources for response
        sources = []
        for source in context_sources[:5]:  # Top 5 sources
            sources.append({
                'id': source.get('id'),
                'title': source.get('title', ''),
                'score': source.get('score', 0.0),
                'type': source.get('type', 'unknown')
            })
        
        return {
            'confidence': confidence,
            'sources': sources
        }
    except Exception as e:
        logger.error(f"Error in validate_node: {e}")
        return {
            'confidence': 0.0,
            'sources': []
        }


def store_interaction_node(state: AgentState) -> Dict[str, Any]:
    """Store interaction in Neo4j graph"""
    try:
        from ..neo4j_service import Neo4jService
        from datetime import datetime
        import hashlib
        
        neo4j_service = Neo4jService()
        student_id = state.get('student_id', '')
        question = state.get('question', '')
        answer = state.get('answer', '')
        sources = state.get('sources', [])
        
        # Create interaction ID
        interaction_id = f"interaction_{student_id}_{hashlib.md5(question.encode()).hexdigest()[:8]}"
        
        # Create interaction node
        neo4j_service.create_knowledge_node(
            node_id=interaction_id,
            node_type="Interaction",
            properties={
                'question': question,
                'answer': answer,
                'timestamp': datetime.now().isoformat(),
                'confidence': state.get('confidence', 0.0)
            }
        )
        
        # Link to student
        neo4j_service.create_relationship(
            from_id=student_id,
            from_type="Student",
            to_id=interaction_id,
            to_type="Interaction",
            relationship_type="ASKED"
        )
        
        # Link to sources
        for source in sources[:3]:  # Top 3 sources
            source_id = source.get('id')
            if source_id:
                neo4j_service.create_relationship(
                    from_id=interaction_id,
                    from_type="Interaction",
                    to_id=source_id,
                    to_type="Knowledge",
                    relationship_type="USED_SOURCE",
                    properties={'score': source.get('score', 0.0)}
                )
        
        logger.info(f"Stored interaction: {interaction_id}")
        
        return {}
    except Exception as e:
        logger.error(f"Error in store_interaction_node: {e}")
        return {}

