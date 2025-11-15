from typing import Dict, List, Any, Optional
import logging
from datetime import datetime
from .vector_service import VectorStoreService
from .neo4j_service import Neo4jService
from .langgraph_service import LangGraphService
import os

logger = logging.getLogger(__name__)


class AIAgentService:
    """Service for AI agent interactions using Neo4j + Vector Store"""
    
    def __init__(self, use_langgraph: bool = False):
        """
        Initialize AI Agent Service.
        
        Args:
            use_langgraph: Whether to use LangGraph by default for answering questions
        """
        self.vector_service = VectorStoreService()
        self.neo4j_service = Neo4jService()
        self.neo4j_service.connect()
        self.use_langgraph = use_langgraph
        self._langgraph_service = None
    
    @property
    def langgraph_service(self):
        """Lazy load LangGraph service"""
        if self._langgraph_service is None:
            enable_checkpoint = os.getenv('LANGGRAPH_PERSIST', 'False').lower() == 'true'
            self._langgraph_service = LangGraphService(enable_checkpoint=enable_checkpoint)
        return self._langgraph_service
    
    def initialize_knowledge_base(self):
        """Initialize vector indexes and knowledge base structure"""
        try:
            # Create vector indexes for different node types
            self.neo4j_service.create_vector_index(
                index_name='course_vector_index',
                node_label='Course',
                property_key='embedding',
                dimensions=self.vector_service.embedding_dimensions
            )
            
            self.neo4j_service.create_vector_index(
                index_name='concept_vector_index',
                node_label='Concept',
                property_key='embedding',
                dimensions=self.vector_service.embedding_dimensions
            )
            
            self.neo4j_service.create_vector_index(
                index_name='lesson_vector_index',
                node_label='Lesson',
                property_key='embedding',
                dimensions=self.vector_service.embedding_dimensions
            )
            
            self.neo4j_service.create_vector_index(
                index_name='Knowledge_vector_index',
                node_label='Knowledge',
                property_key='embedding',
                dimensions=self.vector_service.embedding_dimensions
            )
            
            logger.info("Knowledge base initialized")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize knowledge base: {e}")
            return False
    
    def store_course_knowledge(
        self,
        course_id: str,
        title: str,
        description: str,
        content: str,
        metadata: Dict[str, Any]
    ):
        """Store course knowledge in graph + vector store"""
        try:
            # Store course node with embedding
            full_text = f"{title}\n{description}\n{content}"
            success = self.vector_service.store_document(
                document_id=course_id,
                content=full_text,
                metadata={
                    'title': title,
                    'description': description,
                    'type': 'course',
                    **metadata
                },
                node_type="Course"
            )
            
            if not success:
                return False
            
            # Extract concepts and create relationships
            # This would use NLP to extract key concepts
            concepts = self._extract_concepts(content)
            
            for concept in concepts:
                concept_id = f"concept_{concept.replace(' ', '_').lower()}"
                self.vector_service.store_document(
                    document_id=concept_id,
                    content=concept,
                    metadata={'type': 'concept'},
                    node_type="Concept"
                )
                
                # Create relationship
                self.neo4j_service.create_relationship(
                    from_id=course_id,
                    from_type="Course",
                    to_id=concept_id,
                    to_type="Concept",
                    relationship_type="CONTAINS"
                )
            
            return True
        except Exception as e:
            logger.error(f"Failed to store course knowledge: {e}")
            return False
    
    def answer_student_question(
        self,
        student_id: str,
        question: str,
        context: Optional[Dict[str, Any]] = None,
        use_langgraph: Optional[bool] = None
    ) -> Dict[str, Any]:
        """
        Answer student question using RAG.
        
        Args:
            student_id: Student identifier
            question: Student's question
            context: Additional context (course_id, lesson_id, etc.)
            use_langgraph: Override default LangGraph usage (None = use default)
        
        Returns:
            Dictionary with answer, sources, confidence, etc.
        """
        # Determine whether to use LangGraph
        should_use_langgraph = use_langgraph if use_langgraph is not None else self.use_langgraph
        
        if should_use_langgraph:
            return self.answer_with_langgraph(student_id, question, context)
        else:
            return self._answer_with_linear_rag(student_id, question, context)
    
    def answer_with_langgraph(
        self,
        student_id: str,
        question: str,
        context: Optional[Dict[str, Any]] = None,
        thread_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Answer student question using LangGraph RAG workflow.
        
        Args:
            student_id: Student identifier
            question: Student's question
            context: Additional context (course_id, lesson_id, etc.)
            thread_id: Conversation thread ID for checkpointing
        
        Returns:
            Dictionary with answer, sources, confidence, etc.
        """
        try:
            result = self.langgraph_service.answer_question(
                question=question,
                student_id=student_id,
                context=context,
                thread_id=thread_id
            )
            logger.info(f"LangGraph answered question for student {student_id}: confidence={result.get('confidence', 0.0):.2f}")
            return result
        except Exception as e:
            logger.error(f"Failed to answer with LangGraph: {e}", exc_info=True)
            # Fallback to linear RAG
            logger.info("Falling back to linear RAG")
            return self._answer_with_linear_rag(student_id, question, context)
    
    def _answer_with_linear_rag(
        self,
        student_id: str,
        question: str,
        context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Answer student question using linear RAG (original implementation)"""
        try:
            # 1. Semantic search for relevant knowledge
            search_results = self.vector_service.hybrid_search(
                query=question,
                node_label="Knowledge",
                limit=5
            )
            
            # 2. Get student's learning context from graph
            student_context = self._get_student_context(student_id)
            
            # 3. Build context for LLM
            context_text = self._build_context(search_results, student_context)
            
            # 4. Generate answer (this would call your LLM API)
            answer = self._generate_answer(question, context_text)
            
            # 5. Store interaction in graph
            self._store_interaction(student_id, question, answer, search_results)
            
            return {
                'answer': answer,
                'sources': [self._format_source(r) for r in search_results[:3]],
                'confidence': self._calculate_confidence(search_results)
            }
        except Exception as e:
            logger.error(f"Failed to answer student question: {e}")
            return {
                'answer': 'ขออภัย เกิดข้อผิดพลาดในการประมวลผลคำถามของคุณ',
                'sources': [],
                'confidence': 0.0
            }
    
    def recommend_learning_path(
        self,
        student_id: str,
        target_goal: str
    ) -> List[Dict]:
        """Recommend learning path using graph algorithms"""
        try:
            return self.neo4j_service.get_learning_path(student_id, target_goal)
        except Exception as e:
            logger.error(f"Failed to get learning path: {e}")
            return []
    
    def find_similar_courses(
        self,
        course_id: str,
        limit: int = 5
    ) -> List[Dict]:
        """Find similar courses using graph + vector similarity"""
        try:
            # Get course embedding
            course_query = "MATCH (c:Course {id: $course_id}) RETURN c"
            course_result = self.neo4j_service.execute_query(course_query, {'course_id': course_id})
            
            if not course_result:
                return []
            
            course_data = course_result[0].get('c', {})
            course_embedding = course_data.get('embedding') if isinstance(course_data, dict) else None
            
            if not course_embedding:
                # Generate embedding from course content
                course_content = course_data.get('content', course_data.get('text', ''))
                if course_content:
                    course_embedding = self.vector_service.generate_embedding(course_content)
                else:
                    return []
            
            # Vector similarity search
            similar = self.neo4j_service.semantic_search(
                query_embedding=course_embedding,
                index_name='course_vector_index',
                limit=limit + 1  # +1 to exclude the original course
            )
            
            # Filter out the original course
            return [s for s in similar if self._get_node_id(s.get('node')) != course_id][:limit]
        except Exception as e:
            logger.error(f"Failed to find similar courses: {e}")
            return []
    
    def _extract_concepts(self, text: str) -> List[str]:
        """Extract key concepts from text (simplified - use NLP in production)"""
        # This is a placeholder - use proper NLP/NER in production
        # For now, extract simple keywords
        import re
        # Extract words (Thai and English)
        words = re.findall(r'\b\w+\b', text.lower())
        # Filter common words
        stop_words = {'the', 'is', 'at', 'which', 'on', 'a', 'an', 'and', 'or', 'but', 'in', 'to', 'for', 'of', 'with', 'by'}
        keywords = [w for w in words if w not in stop_words and len(w) > 3]
        # Return top 10 unique keywords
        return list(set(keywords))[:10]
    
    def _get_student_context(self, student_id: str) -> Dict[str, Any]:
        """Get student's learning context from graph"""
        query = """
        MATCH (s:Student {id: $student_id})
        OPTIONAL MATCH (s)-[:ENROLLED_IN]->(c:Course)
        OPTIONAL MATCH (s)-[:COMPLETED]->(l:Lesson)
        RETURN s, collect(DISTINCT c) as courses, collect(DISTINCT l) as completed_lessons
        """
        result = self.neo4j_service.execute_query(query, {'student_id': student_id})
        return result[0] if result else {}
    
    def _build_context(self, search_results: List[Dict], student_context: Dict) -> str:
        """Build context string for LLM"""
        context_parts = []
        
        # Add search results
        for result in search_results:
            node = result.get('node', {})
            if isinstance(node, dict):
                content = node.get('content', node.get('text', ''))
                if content:
                    context_parts.append(content)
        
        # Add student context
        if student_context:
            courses = student_context.get('courses', [])
            if courses:
                course_titles = [c.get('title', '') for c in courses if isinstance(c, dict)]
                if course_titles:
                    context_parts.append(f"นักเรียนกำลังเรียนคอร์ส: {', '.join(course_titles)}")
        
        return "\n\n".join(context_parts) if context_parts else ""
    
    def _generate_answer(self, question: str, context: str) -> str:
        """Generate answer using LLM (placeholder - integrate with OpenAI/Claude)"""
        # This would call your LLM API
        # For now, return a contextual response
        if context:
            return f"จากข้อมูลที่มี: {context[:200]}... คำตอบสำหรับคำถาม '{question}' จะถูกสร้างโดย AI Instructor"
        else:
            return f"คำถามของคุณ: '{question}' กำลังถูกประมวลผลโดย AI Instructor"
    
    def _calculate_confidence(self, search_results: List[Dict]) -> float:
        """Calculate confidence score based on search results"""
        if not search_results:
            return 0.0
        
        scores = [r.get('score', 0.0) for r in search_results if isinstance(r.get('score'), (int, float))]
        return sum(scores) / len(scores) if scores else 0.0
    
    def _store_interaction(
        self,
        student_id: str,
        question: str,
        answer: str,
        sources: List[Dict]
    ):
        """Store student-AI interaction in graph"""
        try:
            import hashlib
            interaction_id = f"interaction_{student_id}_{hashlib.md5(question.encode()).hexdigest()[:8]}"
            
            # Create interaction node
            self.neo4j_service.create_knowledge_node(
                node_id=interaction_id,
                node_type="Interaction",
                properties={
                    'question': question,
                    'answer': answer,
                    'timestamp': datetime.now().isoformat()
                }
            )
            
            # Link to student
            self.neo4j_service.create_relationship(
                from_id=student_id,
                from_type="Student",
                to_id=interaction_id,
                to_type="Interaction",
                relationship_type="ASKED"
            )
            
            # Link to sources
            for source in sources[:3]:  # Top 3 sources
                source_id = self._get_node_id(source.get('node'))
                if source_id:
                    self.neo4j_service.create_relationship(
                        from_id=interaction_id,
                        from_type="Interaction",
                        to_id=source_id,
                        to_type="Knowledge",
                        relationship_type="USED_SOURCE"
                    )
        except Exception as e:
            logger.error(f"Failed to store interaction: {e}")
    
    def _get_node_id(self, node: Any) -> Optional[str]:
        """Extract node ID from node object"""
        if isinstance(node, dict):
            return node.get('id')
        return None
    
    def _format_source(self, result: Dict) -> Dict[str, Any]:
        """Format search result as source"""
        node = result.get('node', {})
        if isinstance(node, dict):
            return {
                'id': node.get('id'),
                'title': node.get('title', node.get('content', '')[:100]),
                'score': result.get('score', 0.0)
            }
        return {'id': None, 'title': '', 'score': 0.0}

