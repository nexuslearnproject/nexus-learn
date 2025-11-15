from sentence_transformers import SentenceTransformer
from typing import List, Dict, Any
import logging
from .neo4j_service import Neo4jService
import os

logger = logging.getLogger(__name__)


class VectorStoreService:
    """Service for managing vector embeddings and semantic search"""
    
    def __init__(self):
        self.model = None
        self.neo4j_service = Neo4jService()
        self.embedding_dimensions = int(os.getenv('EMBEDDING_DIMENSIONS', '384'))
        self.model_name = os.getenv('EMBEDDING_MODEL', 'all-MiniLM-L6-v2')
        
    def load_model(self, model_name: str = None):
        """Load sentence transformer model"""
        if model_name:
            self.model_name = model_name
        
        try:
            self.model = SentenceTransformer(self.model_name)
            logger.info(f"Loaded embedding model: {self.model_name}")
        except Exception as e:
            logger.error(f"Failed to load embedding model: {e}")
            raise
    
    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for a text"""
        if not self.model:
            self.load_model()
        
        try:
            embedding = self.model.encode(text, convert_to_numpy=True)
            return embedding.tolist()
        except Exception as e:
            logger.error(f"Failed to generate embedding: {e}")
            raise
    
    def generate_embeddings_batch(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for multiple texts"""
        if not self.model:
            self.load_model()
        
        try:
            embeddings = self.model.encode(texts, convert_to_numpy=True)
            return embeddings.tolist()
        except Exception as e:
            logger.error(f"Failed to generate batch embeddings: {e}")
            raise
    
    def store_document(
        self,
        document_id: str,
        content: str,
        metadata: Dict[str, Any],
        node_type: str = "Knowledge"
    ) -> bool:
        """Store a document with its embedding in Neo4j"""
        try:
            embedding = self.generate_embedding(content)
            
            properties = {
                'content': content,
                'text': content,  # For full-text search
                **metadata
            }
            
            return self.neo4j_service.create_knowledge_node(
                node_id=document_id,
                node_type=node_type,
                properties=properties,
                embedding=embedding
            )
        except Exception as e:
            logger.error(f"Failed to store document: {e}")
            return False
    
    def semantic_search(
        self,
        query: str,
        node_label: str = "Knowledge",
        limit: int = 10,
        threshold: float = 0.7
    ) -> List[Dict]:
        """Perform semantic search"""
        try:
            query_embedding = self.generate_embedding(query)
            index_name = f"{node_label}_vector_index"
            
            # Use Neo4j vector index for search
            results = self.neo4j_service.semantic_search(
                query_embedding=query_embedding,
                index_name=index_name,
                limit=limit,
                threshold=threshold
            )
            
            return results
        except Exception as e:
            logger.error(f"Semantic search failed: {e}")
            return []
    
    def hybrid_search(
        self,
        query: str,
        node_label: str = "Knowledge",
        limit: int = 10
    ) -> List[Dict]:
        """Combine semantic search with graph relationships"""
        # Semantic search
        semantic_results = self.semantic_search(query, node_label, limit=limit)
        
        # Get related nodes from graph
        related_results = []
        for result in semantic_results[:5]:  # Top 5 semantic results
            node = result.get('node', {})
            node_id = node.get('id') if isinstance(node, dict) else None
            
            if node_id:
                related = self.neo4j_service.get_related_concepts(
                    concept_id=node_id,
                    relationship_types=['RELATED_TO', 'SIMILAR_TO'],
                    depth=1
                )
                related_results.extend(related)
        
        # Combine and deduplicate
        all_results = semantic_results + related_results
        seen_ids = set()
        unique_results = []
        
        for result in all_results:
            node = result.get('node', {})
            node_id = node.get('id') if isinstance(node, dict) else None
            
            if node_id and node_id not in seen_ids:
                seen_ids.add(node_id)
                unique_results.append(result)
                if len(unique_results) >= limit:
                    break
        
        return unique_results

