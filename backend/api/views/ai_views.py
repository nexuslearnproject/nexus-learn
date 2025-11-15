from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
import logging
from ..services.ai_agent_service import AIAgentService

logger = logging.getLogger(__name__)

# Initialize AI agent service (singleton pattern)
_ai_agent = None

def get_ai_agent():
    """Get or create AI agent service instance"""
    global _ai_agent
    if _ai_agent is None:
        from django.conf import settings
        use_langgraph = getattr(settings, 'LANGGRAPH_DEFAULT_ENABLED', False)
        _ai_agent = AIAgentService(use_langgraph=use_langgraph)
        # Initialize knowledge base on first use
        _ai_agent.initialize_knowledge_base()
    return _ai_agent


@api_view(['POST'])
@permission_classes([AllowAny])
def ask_question(request):
    """Student asks AI agent a question (uses LangGraph if enabled)"""
    try:
        student_id = request.data.get('student_id')
        question = request.data.get('question')
        context = request.data.get('context')
        use_langgraph = request.data.get('use_langgraph')  # Optional override
        
        if not student_id or not question:
            return Response(
                {'error': 'student_id and question are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ai_agent = get_ai_agent()
        result = ai_agent.answer_student_question(
            student_id=student_id,
            question=question,
            context=context,
            use_langgraph=use_langgraph
        )
        
        return Response(result, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error in ask_question: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def ask_graph(request):
    """Student asks AI agent a question using LangGraph workflow"""
    try:
        student_id = request.data.get('student_id')
        question = request.data.get('question')
        context = request.data.get('context')
        thread_id = request.data.get('thread_id')  # For conversation continuity
        
        if not student_id or not question:
            return Response(
                {'error': 'student_id and question are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ai_agent = get_ai_agent()
        result = ai_agent.answer_with_langgraph(
            student_id=student_id,
            question=question,
            context=context,
            thread_id=thread_id
        )
        
        return Response(result, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error in ask_graph: {e}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def ask_stream(request):
    """Stream answer generation in real-time using LangGraph"""
    try:
        from django.http import StreamingHttpResponse
        import json
        import asyncio
        
        student_id = request.data.get('student_id')
        question = request.data.get('question')
        context = request.data.get('context')
        thread_id = request.data.get('thread_id')
        
        if not student_id or not question:
            return Response(
                {'error': 'student_id and question are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ai_agent = get_ai_agent()
        
        async def generate():
            """Async generator function for streaming response"""
            try:
                async for event in ai_agent.langgraph_service.stream_answer(
                    question=question,
                    student_id=student_id,
                    context=context,
                    thread_id=thread_id
                ):
                    yield f"data: {json.dumps(event)}\n\n"
            except Exception as e:
                logger.error(f"Error in stream: {e}")
                yield f"data: {json.dumps({'error': str(e)})}\n\n"
        
        def sync_generate():
            """Sync wrapper for async generator"""
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                async_gen = generate()
                while True:
                    try:
                        yield loop.run_until_complete(async_gen.__anext__())
                    except StopAsyncIteration:
                        break
            finally:
                loop.close()
        
        response = StreamingHttpResponse(
            sync_generate(),
            content_type='text/event-stream'
        )
        response['Cache-Control'] = 'no-cache'
        response['X-Accel-Buffering'] = 'no'
        return response
    except Exception as e:
        logger.error(f"Error in ask_stream: {e}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def recommend_path(request, student_id):
    """Get recommended learning path"""
    try:
        target_goal = request.query_params.get('goal', 'exam_preparation')
        
        ai_agent = get_ai_agent()
        path = ai_agent.recommend_learning_path(student_id, target_goal)
        
        return Response({'path': path}, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error in recommend_path: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def similar_courses(request, course_id):
    """Find similar courses"""
    try:
        limit = int(request.query_params.get('limit', 5))
        
        ai_agent = get_ai_agent()
        similar = ai_agent.find_similar_courses(course_id, limit)
        
        return Response({'courses': similar}, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error in similar_courses: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def store_course_knowledge(request):
    """Store course knowledge in graph + vector store"""
    try:
        course_id = request.data.get('course_id')
        title = request.data.get('title')
        description = request.data.get('description', '')
        content = request.data.get('content', '')
        metadata = request.data.get('metadata', {})
        
        if not course_id or not title:
            return Response(
                {'error': 'course_id and title are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ai_agent = get_ai_agent()
        success = ai_agent.store_course_knowledge(
            course_id=course_id,
            title=title,
            description=description,
            content=content,
            metadata=metadata
        )
        
        if success:
            return Response(
                {'message': 'Course knowledge stored successfully'},
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                {'error': 'Failed to store course knowledge'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    except Exception as e:
        logger.error(f"Error in store_course_knowledge: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def initialize_knowledge_base(request):
    """Initialize knowledge base (admin endpoint)"""
    try:
        ai_agent = get_ai_agent()
        success = ai_agent.initialize_knowledge_base()
        
        if success:
            return Response(
                {'message': 'Knowledge base initialized successfully'},
                status=status.HTTP_200_OK
            )
        else:
            return Response(
                {'error': 'Failed to initialize knowledge base'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    except Exception as e:
        logger.error(f"Error in initialize_knowledge_base: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def semantic_search(request):
    """Perform semantic search"""
    try:
        query = request.data.get('query')
        node_label = request.data.get('node_label', 'Knowledge')
        limit = int(request.data.get('limit', 10))
        threshold = float(request.data.get('threshold', 0.7))
        
        if not query:
            return Response(
                {'error': 'query is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        ai_agent = get_ai_agent()
        results = ai_agent.vector_service.semantic_search(
            query=query,
            node_label=node_label,
            limit=limit,
            threshold=threshold
        )
        
        return Response({'results': results}, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error in semantic_search: {e}")
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def ask_async(request):
    """Submit question for async processing via Celery"""
    try:
        from api.tasks.langgraph_tasks import process_langgraph_question
        
        student_id = request.data.get('student_id')
        question = request.data.get('question')
        context = request.data.get('context')
        thread_id = request.data.get('thread_id')
        
        if not student_id or not question:
            return Response(
                {'error': 'student_id and question are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Submit task to Celery
        task = process_langgraph_question.delay(
            question=question,
            student_id=student_id,
            context=context,
            thread_id=thread_id
        )
        
        return Response(
            {
                'task_id': task.id,
                'status': 'PENDING',
                'message': 'Question submitted for processing'
            },
            status=status.HTTP_202_ACCEPTED
        )
    except Exception as e:
        logger.error(f"Error submitting async question: {e}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def get_task_status(request, task_id):
    """Get status of async task"""
    try:
        from api.tasks.langgraph_tasks import get_task_status
        
        status_info = get_task_status(task_id)
        
        return Response(status_info, status=status.HTTP_200_OK)
    except Exception as e:
        logger.error(f"Error getting task status: {e}", exc_info=True)
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

