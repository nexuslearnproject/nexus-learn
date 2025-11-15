from django.urls import path, include
from rest_framework.routers import DefaultRouter
import importlib.util
import os

# Import from views.py file (not views package) - workaround for package shadowing
views_file_path = os.path.join(os.path.dirname(__file__), 'views.py')
spec = importlib.util.spec_from_file_location("api.views_module", views_file_path)
views_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(views_module)

from .views import ai_views

router = DefaultRouter()
router.register(r'items', views_module.ItemViewSet, basename='item')

urlpatterns = [
    path('', include(router.urls)),
    path('health/', views_module.health_check, name='health_check'),
    
    # AI Agent endpoints
    path('ai/ask/', ai_views.ask_question, name='ai_ask'),
    path('ai/ask-graph/', ai_views.ask_graph, name='ai_ask_graph'),
    path('ai/ask-stream/', ai_views.ask_stream, name='ai_ask_stream'),
    path('ai/ask-async/', ai_views.ask_async, name='ai_ask_async'),
    path('ai/tasks/<str:task_id>/status/', ai_views.get_task_status, name='ai_task_status'),
    path('ai/students/<str:student_id>/recommend-path/', ai_views.recommend_path, name='ai_recommend_path'),
    path('ai/courses/<str:course_id>/similar/', ai_views.similar_courses, name='ai_similar_courses'),
    path('ai/courses/store-knowledge/', ai_views.store_course_knowledge, name='ai_store_course_knowledge'),
    path('ai/knowledge-base/initialize/', ai_views.initialize_knowledge_base, name='ai_initialize_kb'),
    path('ai/search/', ai_views.semantic_search, name='ai_semantic_search'),
]

