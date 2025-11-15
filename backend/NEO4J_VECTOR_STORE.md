# Neo4j + Vector Store สำหรับ AI Agent

## ภาพรวม

ระบบนี้ใช้ Neo4j (Graph Database) ร่วมกับ Vector Store เพื่อสร้าง Knowledge Base สำหรับ AI Agent ที่สามารถ:
- เก็บความรู้ในรูปแบบ Graph (ความสัมพันธ์ระหว่าง concepts, courses, students)
- ใช้ Vector Embeddings สำหรับ Semantic Search
- รองรับ RAG (Retrieval Augmented Generation) สำหรับตอบคำถามนักเรียน

## สถาปัตยกรรม

```
┌─────────────┐
│   Django    │
│   Backend   │
└──────┬──────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────┐    ┌──────────┐
│  Neo4j   │    │  Vector  │
│  Graph   │    │  Store   │
│  DB      │    │ (Embed.) │
└──────────┘    └──────────┘
```

## การติดตั้ง

### 1. เพิ่ม Environment Variables

เพิ่มในไฟล์ `.env`:

```env
# Neo4j Configuration
NEO4J_URI=bolt://neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=neo4j_password

# Vector Store
EMBEDDING_MODEL=all-MiniLM-L6-v2
EMBEDDING_DIMENSIONS=384
```

### 2. รัน Docker Compose

```bash
docker-compose up -d neo4j
```

### 3. Initialize Knowledge Base

```bash
# ผ่าน Django management command
docker-compose exec backend python manage.py init_neo4j

# หรือผ่าน API
curl -X POST http://localhost:8000/api/ai/knowledge-base/initialize/
```

## API Endpoints

### 1. ถามคำถาม AI Agent

```bash
POST /api/ai/ask/
Content-Type: application/json

{
  "student_id": "student_123",
  "question": "Object-oriented programming คืออะไร?",
  "context": {
    "course_id": "course_1",
    "lesson_id": "lesson_5"
  }
}
```

**Response:**
```json
{
  "answer": "คำตอบจาก AI...",
  "sources": [
    {
      "id": "concept_oop",
      "title": "Object-Oriented Programming",
      "score": 0.95
    }
  ],
  "confidence": 0.92
}
```

### 2. แนะนำ Learning Path

```bash
GET /api/ai/students/{student_id}/recommend-path/?goal=exam_preparation
```

### 3. หาคอร์สที่คล้ายกัน

```bash
GET /api/ai/courses/{course_id}/similar/?limit=5
```

### 4. เก็บ Course Knowledge

```bash
POST /api/ai/courses/store-knowledge/
Content-Type: application/json

{
  "course_id": "course_1",
  "title": "Advanced Programming",
  "description": "เรียนรู้การเขียนโปรแกรมขั้นสูง",
  "content": "เนื้อหาคอร์สทั้งหมด...",
  "metadata": {
    "level": "advanced",
    "category": "programming"
  }
}
```

### 5. Semantic Search

```bash
POST /api/ai/search/
Content-Type: application/json

{
  "query": "การเขียนโปรแกรม Python",
  "node_label": "Knowledge",
  "limit": 10,
  "threshold": 0.7
}
```

## การใช้งานใน Code

### Python Example

```python
from api.services.ai_agent_service import AIAgentService

# Initialize
ai_agent = AIAgentService()
ai_agent.initialize_knowledge_base()

# Store course knowledge
ai_agent.store_course_knowledge(
    course_id="course_1",
    title="Advanced Programming",
    description="Learn advanced programming",
    content="Full course content...",
    metadata={'level': 'advanced'}
)

# Answer student question
result = ai_agent.answer_student_question(
    student_id="student_123",
    question="What is OOP?",
    context={'course_id': 'course_1'}
)

print(result['answer'])
```

## โครงสร้าง Graph ใน Neo4j

### Node Types:
- **Student**: นักเรียน
- **Course**: คอร์สเรียน
- **Lesson**: บทเรียน
- **Concept**: แนวคิด/หัวข้อ
- **Knowledge**: ข้อมูลความรู้
- **Interaction**: การโต้ตอบระหว่างนักเรียนและ AI

### Relationship Types:
- `ENROLLED_IN`: นักเรียนลงทะเบียนคอร์ส
- `CONTAINS`: คอร์สมีแนวคิด
- `RELATED_TO`: แนวคิดเกี่ยวข้องกัน
- `PREREQUISITE`: แนวคิดเป็น prerequisite
- `SIMILAR_TO`: คอร์ส/แนวคิดคล้ายกัน
- `ASKED`: นักเรียนถามคำถาม
- `USED_SOURCE`: Interaction ใช้แหล่งข้อมูล

## Vector Indexes

ระบบจะสร้าง Vector Indexes อัตโนมัติสำหรับ:
- `course_vector_index`: สำหรับ Course nodes
- `concept_vector_index`: สำหรับ Concept nodes
- `lesson_vector_index`: สำหรับ Lesson nodes
- `Knowledge_vector_index`: สำหรับ Knowledge nodes

## การ Debug

### เช็ค Neo4j Connection

```bash
# เข้า Neo4j Browser
http://localhost:7474

# Username: neo4j
# Password: neo4j_password (หรือตามที่ตั้งไว้)
```

### Cypher Queries ตัวอย่าง

```cypher
// ดู Course ทั้งหมด
MATCH (c:Course) RETURN c LIMIT 10

// ดู Concept และความสัมพันธ์
MATCH (c:Concept)-[r]-(related)
RETURN c, r, related LIMIT 20

// Semantic Search (manual)
MATCH (n:Knowledge)
WHERE n.embedding IS NOT NULL
RETURN n LIMIT 10
```

## Performance Tips

1. **Batch Operations**: ใช้ `generate_embeddings_batch()` สำหรับหลาย documents
2. **Index Management**: สร้าง indexes สำหรับ properties ที่ query บ่อย
3. **Connection Pooling**: Neo4j driver ใช้ connection pooling อัตโนมัติ
4. **Caching**: Cache embeddings สำหรับ documents ที่ไม่เปลี่ยน

## Troubleshooting

### Neo4j ไม่เชื่อมต่อ
- ตรวจสอบว่า Neo4j container รันอยู่: `docker-compose ps`
- ตรวจสอบ environment variables
- ดู logs: `docker-compose logs neo4j`

### Vector Index ไม่สร้าง
- ตรวจสอบว่าใช้ Neo4j 5.x+
- ดู logs ใน backend: `docker-compose logs backend`

### Embedding Model ไม่โหลด
- Model จะดาวน์โหลดอัตโนมัติครั้งแรก (อาจใช้เวลานาน)
- ตรวจสอบ disk space
- ดู logs: `docker-compose logs backend`

## Next Steps

1. **Integrate LLM**: เชื่อมต่อกับ OpenAI/Claude สำหรับ generate answers
2. **Advanced NLP**: ใช้ NER (Named Entity Recognition) สำหรับ extract concepts
3. **Graph Algorithms**: ใช้ GDS (Graph Data Science) สำหรับ recommendation
4. **Monitoring**: เพิ่ม logging และ monitoring สำหรับ production

