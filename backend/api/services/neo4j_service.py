from neo4j import GraphDatabase
import os
from typing import List, Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)


class Neo4jService:
    """Service for interacting with Neo4j graph database"""
    
    def __init__(self):
        self.uri = os.getenv('NEO4J_URI', 'bolt://neo4j:7687')
        self.user = os.getenv('NEO4J_USER', 'neo4j')
        self.password = os.getenv('NEO4J_PASSWORD', 'neo4j_password')
        self.driver = None
        
    def connect(self):
        """Establish connection to Neo4j"""
        try:
            self.driver = GraphDatabase.driver(
                self.uri,
                auth=(self.user, self.password)
            )
            # Verify connectivity
            self.driver.verify_connectivity()
            logger.info("Connected to Neo4j successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Neo4j: {e}")
            return False
    
    def close(self):
        """Close Neo4j connection"""
        if self.driver:
            self.driver.close()
    
    def execute_query(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict]:
        """Execute a Cypher query"""
        if not self.driver:
            self.connect()
        
        try:
            with self.driver.session() as session:
                result = session.run(query, parameters or {})
                return [record.data() for record in result]
        except Exception as e:
            logger.error(f"Error executing query: {e}")
            return []
    
    def create_vector_index(self, index_name: str, node_label: str, property_key: str, dimensions: int = 384):
        """Create a vector index in Neo4j (Neo4j 5.x+)"""
        # Check if index already exists
        check_query = f"SHOW INDEXES WHERE name = '{index_name}'"
        existing = self.execute_query(check_query)
        
        if existing:
            logger.info(f"Vector index '{index_name}' already exists")
            return True
        
        query = f"""
        CREATE VECTOR INDEX {index_name} IF NOT EXISTS
        FOR (n:{node_label})
        ON n.{property_key}
        OPTIONS {{
            indexConfig: {{
                `vector.dimensions`: {dimensions},
                `vector.similarity_function`: 'cosine'
            }}
        }}
        """
        try:
            self.execute_query(query)
            logger.info(f"Vector index '{index_name}' created successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to create vector index: {e}")
            return False
    
    def create_knowledge_node(
        self,
        node_id: str,
        node_type: str,
        properties: Dict[str, Any],
        embedding: Optional[List[float]] = None
    ) -> bool:
        """Create a knowledge node with optional embedding"""
        query = f"""
        MERGE (n:{node_type} {{id: $node_id}})
        SET n += $properties
        """
        
        params = {
            'node_id': node_id,
            'properties': properties.copy()
        }
        
        if embedding:
            params['properties']['embedding'] = embedding
        
        try:
            self.execute_query(query, params)
            return True
        except Exception as e:
            logger.error(f"Failed to create knowledge node: {e}")
            return False
    
    def create_relationship(
        self,
        from_id: str,
        from_type: str,
        to_id: str,
        to_type: str,
        relationship_type: str,
        properties: Dict[str, Any] = None
    ) -> bool:
        """Create a relationship between two nodes"""
        query = f"""
        MATCH (a:{from_type} {{id: $from_id}})
        MATCH (b:{to_type} {{id: $to_id}})
        MERGE (a)-[r:{relationship_type}]->(b)
        """
        
        if properties:
            query += " SET r += $properties"
        
        params = {
            'from_id': from_id,
            'to_id': to_id,
            'properties': properties or {}
        }
        
        try:
            self.execute_query(query, params)
            return True
        except Exception as e:
            logger.error(f"Failed to create relationship: {e}")
            return False
    
    def semantic_search(
        self,
        query_embedding: List[float],
        index_name: str,
        limit: int = 10,
        threshold: float = 0.7
    ) -> List[Dict]:
        """Perform semantic search using vector similarity"""
        # For Neo4j 5.x+, use vector index query
        query = f"""
        CALL db.index.vector.queryNodes(
            '{index_name}',
            {limit},
            $query_embedding
        )
        YIELD node, score
        WHERE score >= $threshold
        RETURN node, score
        ORDER BY score DESC
        LIMIT $limit
        """
        
        try:
            return self.execute_query(query, {
                'query_embedding': query_embedding,
                'limit': limit,
                'threshold': threshold
            })
        except Exception as e:
            logger.error(f"Semantic search failed: {e}")
            # Fallback to cosine similarity calculation
            return self._cosine_similarity_search(query_embedding, index_name, limit, threshold)
    
    def _cosine_similarity_search(
        self,
        query_embedding: List[float],
        index_name: str,
        limit: int,
        threshold: float
    ) -> List[Dict]:
        """Fallback cosine similarity search"""
        # Extract node label from index name (assumes format: {label}_vector_index)
        node_label = index_name.replace('_vector_index', '')
        
        query = f"""
        MATCH (n:{node_label})
        WHERE n.embedding IS NOT NULL
        WITH n, 
             gds.similarity.cosine(n.embedding, $query_embedding) AS score
        WHERE score >= $threshold
        RETURN n AS node, score
        ORDER BY score DESC
        LIMIT $limit
        """
        
        try:
            return self.execute_query(query, {
                'query_embedding': query_embedding,
                'limit': limit,
                'threshold': threshold
            })
        except Exception as e:
            logger.error(f"Cosine similarity search failed: {e}")
            return []
    
    def get_related_concepts(
        self,
        concept_id: str,
        relationship_types: List[str] = None,
        depth: int = 2
    ) -> List[Dict]:
        """Get related concepts using graph traversal"""
        rel_types = '|'.join(relationship_types or ['RELATED_TO', 'PREREQUISITE', 'SIMILAR_TO'])
        
        query = f"""
        MATCH path = (start:Concept {{id: $concept_id}})-[:{rel_types}*1..{depth}]->(related)
        RETURN DISTINCT related, length(path) as depth
        ORDER BY depth
        LIMIT 50
        """
        
        return self.execute_query(query, {'concept_id': concept_id})
    
    def get_learning_path(
        self,
        student_id: str,
        target_goal: str
    ) -> List[Dict]:
        """Generate learning path using graph algorithms"""
        query = """
        MATCH (student:Student {id: $student_id})
        MATCH (goal:Goal {name: $target_goal})
        
        // Find courses that lead to the goal
        MATCH path = (student)-[:ENROLLED_IN]->(course:Course)-[:LEADS_TO*]->(goal)
        
        RETURN path, 
               reduce(total = 0, rel in relationships(path) | total + coalesce(rel.difficulty, 0)) as totalDifficulty
        ORDER BY totalDifficulty
        LIMIT 10
        """
        
        return self.execute_query(query, {
            'student_id': student_id,
            'target_goal': target_goal
        })

