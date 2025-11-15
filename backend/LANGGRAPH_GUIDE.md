# LangGraph Integration Guide

This guide explains how to use LangGraph for RAG (Retrieval Augmented Generation) workflows in the Nexus Learn platform.

## Overview

LangGraph provides a stateful, multi-step agent workflow that enhances the RAG system with:
- **Conditional Routing**: Automatically routes questions to appropriate workflows based on complexity
- **Multi-step Reasoning**: Breaks complex questions into sub-queries
- **Graph-aware Retrieval**: Uses Neo4j relationships to expand context
- **State Management**: Maintains conversation context across interactions
- **Streaming Support**: Real-time response generation

## Architecture

```
Question → Router → [Simple RAG | Complex RAG | Multi-Hop] → Generate → Validate → Store
```

### Workflow Types

1. **Simple RAG**: Direct answer from single retrieval
   - Use case: Simple factual questions
   - Flow: Retrieve → Combine → Generate → Validate → Store

2. **Complex RAG**: Multi-step retrieval + reasoning
   - Use case: Questions requiring explanation or analysis
   - Flow: Retrieve → Graph Retrieve → Combine → Generate → Validate → Store

3. **Multi-Hop RAG**: Follow-up questions, concept expansion
   - Use case: Questions about prerequisites, relationships, comparisons
   - Flow: Retrieve → Graph Retrieve → Weaviate Retrieve → Combine → Generate → Validate → Store

## Setup

### 1. Install Dependencies

Dependencies are already added to `requirements.txt`. Install them:

```bash
pip install -r requirements.txt
```

### 2. Environment Variables

Add to your `.env` file:

```env
# LangGraph Configuration
LANGGRAPH_LLM_PROVIDER=openai  # or 'anthropic'
LANGGRAPH_LLM_MODEL=gpt-4o-mini  # or 'claude-3-haiku-20240307'
LANGGRAPH_DEBUG=False  # Enable graph visualization
LANGGRAPH_PERSIST=False  # Enable state persistence
LANGGRAPH_DEFAULT_ENABLED=False  # Use LangGraph by default

# LLM API Keys
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key  # If using Anthropic
```

### 3. Initialize Knowledge Base

```bash
python manage.py shell
```

```python
from api.services.ai_agent_service import AIAgentService

agent = AIAgentService()
agent.initialize_knowledge_base()
```

## Usage

### Basic Usage

#### Using LangGraph Explicitly

```python
from api.services.ai_agent_service import AIAgentService

agent = AIAgentService()
result = agent.answer_with_langgraph(
    student_id="student_123",
    question="What are the prerequisites for advanced Python?",
    context={"course_id": "python_101"}
)

print(result['answer'])
print(f"Confidence: {result['confidence']}")
print(f"Sources: {result['sources']}")
```

#### Using API Endpoint

```bash
curl -X POST http://localhost:8000/api/ai/ask-graph/ \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "student_123",
    "question": "What are the prerequisites for advanced Python?",
    "context": {"course_id": "python_101"},
    "thread_id": "conversation_123"
  }'
```

**Response:**
```json
{
  "answer": "The prerequisites for advanced Python include...",
  "sources": [
    {
      "id": "concept_python",
      "title": "Python Programming",
      "score": 0.92,
      "type": "vector_search"
    }
  ],
  "confidence": 0.88,
  "question_type": "complex",
  "retrieval_count": 2,
  "generation_attempts": 1
}
```

### Streaming Responses

For real-time answer generation:

```bash
curl -X POST http://localhost:8000/api/ai/ask-stream/ \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "student_123",
    "question": "Explain object-oriented programming",
    "thread_id": "conversation_123"
  }'
```

The response will be Server-Sent Events (SSE) stream:

```
data: {"node": "retrieve", "state": {"retrieval_count": 1}}
data: {"node": "combine_context", "state": {"sources": [...]}}
data: {"node": "generate", "state": {"answer": "Object-oriented programming..."}}
```

### Conversation Continuity

Use `thread_id` to maintain conversation context:

```python
thread_id = "student_123_conversation_1"

# First question
result1 = agent.answer_with_langgraph(
    student_id="student_123",
    question="What is Python?",
    thread_id=thread_id
)

# Follow-up question (uses previous context)
result2 = agent.answer_with_langgraph(
    student_id="student_123",
    question="What are its main features?",
    thread_id=thread_id  # Same thread_id
)
```

## API Endpoints

### 1. POST `/api/ai/ask/`
Standard question endpoint (uses LangGraph if enabled by default)

**Request:**
```json
{
  "student_id": "student_123",
  "question": "Your question here",
  "context": {"course_id": "course_1"},
  "use_langgraph": true  // Optional override
}
```

### 2. POST `/api/ai/ask-graph/`
Explicit LangGraph endpoint

**Request:**
```json
{
  "student_id": "student_123",
  "question": "Your question here",
  "context": {"course_id": "course_1"},
  "thread_id": "conversation_123"  // Optional, for continuity
}
```

### 3. POST `/api/ai/ask-stream/`
Streaming LangGraph endpoint (Server-Sent Events)

**Request:**
```json
{
  "student_id": "student_123",
  "question": "Your question here",
  "thread_id": "conversation_123"
}
```

## Graph Visualization

To visualize the LangGraph workflow:

1. Enable debug mode:
```env
LANGGRAPH_DEBUG=True
```

2. Use LangGraph Studio or export the graph:

```python
from api.services.langgraph.graph import create_rag_graph

graph = create_rag_graph()
# Export graph visualization
graph.get_graph().draw_mermaid_png(output_file_path="rag_graph.png")
```

## State Management

### AgentState Structure

```python
{
    "question": str,
    "student_id": str,
    "context": Dict[str, Any],
    "messages": List[BaseMessage],
    "retrieved_docs": List[Dict],
    "graph_results": List[Dict],
    "weaviate_results": List[Dict],
    "context": str,
    "context_sources": List[Dict],
    "answer": str,
    "confidence": float,
    "sources": List[Dict],
    "next_step": str,
    "question_type": str,
    "retrieval_count": int,
    "generation_attempts": int
}
```

### Checkpointing

Enable state persistence:

```env
LANGGRAPH_PERSIST=True
```

This allows:
- Conversation history retrieval
- State recovery across sessions
- Multi-turn conversations

## Customization

### Custom Router Logic

Edit `backend/api/services/langgraph/router.py`:

```python
def classify_question(question: str, context: Dict[str, Any] = None) -> str:
    # Add your custom classification logic
    if "prerequisite" in question.lower():
        return "multi_hop"
    # ...
```

### Custom Nodes

Add custom nodes in `backend/api/services/langgraph/nodes.py`:

```python
def custom_node(state: AgentState) -> Dict[str, Any]:
    # Your custom logic
    return {"custom_field": "value"}
```

Then add to graph in `backend/api/services/langgraph/graph.py`:

```python
workflow.add_node("custom", custom_node)
workflow.add_edge("router", "custom")
```

### Custom LLM Configuration

Modify `generate_node` in `nodes.py`:

```python
llm = ChatOpenAI(
    model="gpt-4",
    temperature=0.3,  # Lower temperature for more focused answers
    max_tokens=1000
)
```

## Troubleshooting

### LLM Not Responding

1. Check API keys:
```bash
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY
```

2. Check model availability:
```python
from langchain_openai import ChatOpenAI
llm = ChatOpenAI(model="gpt-4o-mini")
llm.invoke("test")
```

### Low Confidence Scores

- Increase retrieval limit in `retrieve_node`
- Adjust threshold in `semantic_search`
- Add more context sources

### Graph Not Routing Correctly

1. Check router classification:
```python
from api.services.langgraph.router import classify_question
question_type = classify_question("Your question")
print(question_type)
```

2. Enable debug logging:
```python
import logging
logging.getLogger('api.services.langgraph').setLevel(logging.DEBUG)
```

### Neo4j Connection Issues

Ensure Neo4j is running and accessible:

```bash
docker-compose ps neo4j
```

Check connection:
```python
from api.services.neo4j_service import Neo4jService
service = Neo4jService()
service.connect()
```

## Performance Tips

1. **Batch Processing**: Process multiple questions in parallel
2. **Caching**: Cache embeddings for frequently asked questions
3. **Indexing**: Ensure Neo4j vector indexes are created
4. **Streaming**: Use streaming for better UX on long responses
5. **Checkpointing**: Disable checkpointing if not needed for better performance

## Examples

### Example 1: Simple Question

```python
result = agent.answer_with_langgraph(
    student_id="student_123",
    question="What is Python?"
)
# Routes to: simple_rag
# Question type: simple
```

### Example 2: Complex Question

```python
result = agent.answer_with_langgraph(
    student_id="student_123",
    question="Explain how object-oriented programming works in Python"
)
# Routes to: complex_rag
# Question type: complex
# Uses: Retrieve + Graph Retrieve
```

### Example 3: Multi-Hop Question

```python
result = agent.answer_with_langgraph(
    student_id="student_123",
    question="What are the prerequisites for learning advanced Python?"
)
# Routes to: multi_hop_rag
# Question type: multi_hop
# Uses: Retrieve + Graph Retrieve + Weaviate Retrieve
```

## Next Steps

1. **Fine-tune Router**: Improve question classification accuracy
2. **Add Tools**: Integrate external tools (calculator, code executor, etc.)
3. **Multi-Agent**: Create specialized agents for different domains
4. **Evaluation**: Add evaluation metrics for answer quality
5. **Monitoring**: Add observability for graph execution

## References

- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangChain Documentation](https://python.langchain.com/)
- [Neo4j Vector Search](https://neo4j.com/docs/cypher-manual/current/indexes-for-vector-search/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)

