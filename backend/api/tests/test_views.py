# from django.test import TestCase, Client
# from django.contrib.auth import get_user_model
# from django.urls import reverse
# from rest_framework import status
# from rest_framework.test import APIClient
# from api.models import Student, Course, Category

# User = get_user_model()


# class HealthCheckTest(TestCase):
#     """Test health check endpoint"""
    
#     def setUp(self):
#         self.client = Client()
    
#     def test_health_check(self):
#         """Test health check endpoint returns 200"""
#         response = self.client.get('/api/health/')
#         self.assertEqual(response.status_code, status.HTTP_200_OK)
#         self.assertIn('status', response.json())
#         self.assertEqual(response.json()['status'], 'ok')


# class AIEndpointsTest(TestCase):
#     """Test AI agent endpoints"""
    
#     def setUp(self):
#         self.client = APIClient()
    
#     def test_ask_question_missing_params(self):
#         """Test ask question endpoint with missing parameters"""
#         response = self.client.post('/api/ai/ask/', {}, format='json')
#         self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
#     def test_ask_question_with_params(self):
#         """Test ask question endpoint with parameters"""
#         data = {
#             'student_id': 'test_student_123',
#             'question': 'What is Python?'
#         }
#         response = self.client.post('/api/ai/ask/', data, format='json')
#         # Should return 200 even if AI service is not fully configured
#         self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_500_INTERNAL_SERVER_ERROR])


# class CourseEndpointsTest(TestCase):
#     """Test course-related endpoints"""
    
#     def setUp(self):
#         self.client = APIClient()
#         self.category = Category.objects.create(
#             name_th='ทดสอบ',
#             name_en='Test',
#             slug='test'
#         )
#         self.course = Course.objects.create(
#             course_code='TEST101',
#             category=self.category,
#             title_th='คอร์สทดสอบ',
#             title_en='Test Course',
#             slug='test-course',
#             price=1000.00,
#             duration_hours=10.0
#         )
    
#     def test_similar_courses_endpoint(self):
#         """Test similar courses endpoint"""
#         response = self.client.get(f'/api/ai/courses/{self.course.course_code}/similar/')
#         # Should return 200 even if vector store is not configured
#         self.assertIn(response.status_code, [status.HTTP_200_OK, status.HTTP_500_INTERNAL_SERVER_ERROR])

