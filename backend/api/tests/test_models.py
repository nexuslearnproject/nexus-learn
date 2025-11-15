from django.test import TestCase
from django.contrib.auth import get_user_model
from api.models import Student, Course, Category, Enrollment, Assessment, Certificate, Review

User = get_user_model()


class UserModelTest(TestCase):
    """Test User model"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='testpass123'
        )
    
    def test_user_creation(self):
        """Test user can be created"""
        self.assertEqual(self.user.email, 'test@example.com')
        self.assertEqual(self.user.user_type, 'student')
        self.assertFalse(self.user.is_verified)
    
    def test_user_str(self):
        """Test user string representation"""
        self.assertEqual(str(self.user), 'test@example.com')


class StudentModelTest(TestCase):
    """Test Student model"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='student@example.com',
            username='student',
            password='testpass123'
        )
        self.student = Student.objects.create(
            user=self.user,
            student_id='STU001',
            education_level='high_school',
            target_exam='GAT'
        )
    
    def test_student_creation(self):
        """Test student can be created"""
        self.assertEqual(self.student.user, self.user)
        self.assertEqual(self.student.student_id, 'STU001')
        self.assertEqual(self.student.points, 0)
        self.assertEqual(self.student.level, 1)
    
    def test_student_str(self):
        """Test student string representation"""
        self.assertIn('student@example.com', str(self.student))
        self.assertIn('STU001', str(self.student))


class CourseModelTest(TestCase):
    """Test Course model"""
    
    def setUp(self):
        self.category = Category.objects.create(
            name_th='คณิตศาสตร์',
            name_en='Mathematics',
            slug='mathematics'
        )
        self.course = Course.objects.create(
            course_code='MATH101',
            category=self.category,
            title_th='คณิตศาสตร์พื้นฐาน',
            title_en='Basic Mathematics',
            slug='basic-mathematics',
            price=1990.00,
            duration_hours=40.0,
            level='beginner'
        )
    
    def test_course_creation(self):
        """Test course can be created"""
        self.assertEqual(self.course.course_code, 'MATH101')
        self.assertEqual(self.course.category, self.category)
        self.assertEqual(self.course.price, 1990.00)
        self.assertFalse(self.course.is_published)
    
    def test_course_str(self):
        """Test course string representation"""
        self.assertEqual(str(self.course), 'คณิตศาสตร์พื้นฐาน')


class EnrollmentModelTest(TestCase):
    """Test Enrollment model"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='enroll@example.com',
            username='enrolluser',
            password='testpass123'
        )
        self.student = Student.objects.create(
            user=self.user,
            student_id='STU002'
        )
        self.category = Category.objects.create(
            name_th='วิทยาศาสตร์',
            name_en='Science',
            slug='science'
        )
        self.course = Course.objects.create(
            course_code='SCI101',
            category=self.category,
            title_th='วิทยาศาสตร์พื้นฐาน',
            title_en='Basic Science',
            slug='basic-science',
            price=1990.00,
            duration_hours=40.0
        )
        self.enrollment = Enrollment.objects.create(
            student=self.student,
            course=self.course,
            status='active'
        )
    
    def test_enrollment_creation(self):
        """Test enrollment can be created"""
        self.assertEqual(self.enrollment.student, self.student)
        self.assertEqual(self.enrollment.course, self.course)
        self.assertEqual(self.enrollment.status, 'active')
        self.assertEqual(self.enrollment.progress_percentage, 0)
    
    def test_enrollment_unique_together(self):
        """Test that student can only enroll once per course"""
        # Try to create duplicate enrollment
        with self.assertRaises(Exception):
            Enrollment.objects.create(
                student=self.student,
                course=self.course,
                status='active'
            )

