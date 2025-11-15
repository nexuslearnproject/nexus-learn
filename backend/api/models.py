from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator


class User(AbstractUser):
    """Base User model for authentication"""
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    profile_image = models.URLField(max_length=500, blank=True)
    user_type = models.CharField(
        max_length=20,
        choices=[('student', 'Student'), ('admin', 'Admin')],
        default='student'
    )
    language_preference = models.CharField(max_length=10, default='th')
    timezone = models.CharField(max_length=50, default='Asia/Bangkok')
    is_verified = models.BooleanField(default=False)
    email_verified_at = models.DateTimeField(blank=True, null=True)
    last_login = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']

    def __str__(self):
        return self.email


class Student(models.Model):
    """Student learning profile and progress"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student_profile')
    student_id = models.CharField(max_length=20, unique=True, blank=True, null=True)
    
    # Educational Background
    education_level = models.CharField(max_length=50, blank=True)
    school_name = models.CharField(max_length=200, blank=True)
    grade_level = models.CharField(max_length=20, blank=True)
    major = models.CharField(max_length=100, blank=True)
    
    # Learning Preferences
    target_exam = models.CharField(max_length=100, blank=True)  # GAT, PAT, TGAT, etc.
    learning_goals = models.TextField(blank=True)
    learning_style = models.CharField(
        max_length=20,
        choices=[
            ('visual', 'Visual'),
            ('auditory', 'Auditory'),
            ('kinesthetic', 'Kinesthetic'),
            ('reading_writing', 'Reading/Writing'),
            ('mixed', 'Mixed')
        ],
        default='mixed'
    )
    preferred_difficulty = models.CharField(max_length=50, blank=True)
    study_time_preference = models.CharField(max_length=50, blank=True)
    
    # Gamification & Progress
    total_learning_hours = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    points = models.IntegerField(default=0)
    level = models.IntegerField(default=1)
    experience_points = models.IntegerField(default=0)
    next_level_points = models.IntegerField(default=100)
    streak_days = models.IntegerField(default=0)
    longest_streak = models.IntegerField(default=0)
    last_activity_date = models.DateField(blank=True, null=True)
    achievements_earned = models.IntegerField(default=0)
    
    # Statistics
    total_courses_enrolled = models.IntegerField(default=0)
    total_courses_completed = models.IntegerField(default=0)
    total_lessons_completed = models.IntegerField(default=0)
    total_assessments_taken = models.IntegerField(default=0)
    average_assessment_score = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    
    # Subscription & Access
    subscription_tier = models.CharField(
        max_length=20,
        choices=[('free', 'Free'), ('premium', 'Premium'), ('pro', 'Pro')],
        default='free'
    )
    subscription_start_date = models.DateField(blank=True, null=True)
    subscription_end_date = models.DateField(blank=True, null=True)
    trial_used = models.BooleanField(default=False)
    
    # AI Learning Profile (stored as JSON)
    ai_learning_profile = models.JSONField(default=dict, blank=True)
    recommended_study_pace = models.CharField(max_length=50, blank=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'students'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.student_id}"


class Category(models.Model):
    """Course categories"""
    name_th = models.CharField(max_length=100)
    name_en = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100, unique=True)
    description_th = models.TextField(blank=True)
    description_en = models.TextField(blank=True)
    icon = models.CharField(max_length=100, blank=True)
    color = models.CharField(max_length=20, blank=True)
    display_order = models.IntegerField(default=0)
    parent_category = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='subcategories'
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'categories'
        ordering = ['display_order', 'name_th']
        verbose_name_plural = 'Categories'

    def __str__(self):
        return self.name_th


class Course(models.Model):
    """Course metadata (content stored in Weaviate/Neo4j)"""
    course_code = models.CharField(max_length=50, unique=True)
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='courses')
    
    # Basic Info
    title_th = models.CharField(max_length=255)
    title_en = models.CharField(max_length=255, blank=True)
    slug = models.SlugField(max_length=255, unique=True)
    short_description_th = models.CharField(max_length=500, blank=True)
    short_description_en = models.CharField(max_length=500, blank=True)
    
    # Media
    thumbnail_image = models.URLField(max_length=500, blank=True)
    cover_image = models.URLField(max_length=500, blank=True)
    preview_video_url = models.URLField(max_length=500, blank=True)
    trailer_video_url = models.URLField(max_length=500, blank=True)
    
    # Pricing
    price = models.DecimalField(max_digits=10, decimal_places=2)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    currency = models.CharField(max_length=10, default='THB')
    is_free = models.BooleanField(default=False)
    
    # Course Details (metadata only - actual content in Weaviate)
    level = models.CharField(
        max_length=20,
        choices=[
            ('beginner', 'Beginner'),
            ('intermediate', 'Intermediate'),
            ('advanced', 'Advanced'),
            ('expert', 'Expert')
        ],
        default='beginner'
    )
    language = models.CharField(max_length=10, default='th')
    duration_hours = models.DecimalField(max_digits=10, decimal_places=2)
    total_lessons = models.IntegerField(default=0)
    total_sections = models.IntegerField(default=0)
    
    # Metadata (JSON fields)
    prerequisites = models.JSONField(default=list, blank=True)
    learning_outcomes = models.JSONField(default=list, blank=True)
    target_audience = models.JSONField(default=list, blank=True)
    
    # Statistics
    total_students = models.IntegerField(default=0)
    active_students = models.IntegerField(default=0)
    completion_rate = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    average_rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    total_reviews = models.IntegerField(default=0)
    
    # AI-Generated Content Metadata
    is_ai_generated = models.BooleanField(default=True)
    content_version = models.IntegerField(default=1)
    last_ai_update = models.DateTimeField(blank=True, null=True)
    ai_generation_prompt = models.TextField(blank=True)
    
    # Publishing
    is_published = models.BooleanField(default=False)
    published_at = models.DateTimeField(blank=True, null=True)
    featured = models.BooleanField(default=False)
    featured_order = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'courses'
        ordering = ['-created_at']

    def __str__(self):
        return self.title_th


class Enrollment(models.Model):
    """Student course enrollment"""
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='enrollments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='enrollments')
    
    enrollment_date = models.DateTimeField(auto_now_add=True)
    start_date = models.DateTimeField(blank=True, null=True)
    completion_date = models.DateTimeField(blank=True, null=True)
    expected_completion_date = models.DateField(blank=True, null=True)
    progress_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0)
    last_accessed_at = models.DateTimeField(blank=True, null=True)
    
    status = models.CharField(
        max_length=20,
        choices=[
            ('active', 'Active'),
            ('completed', 'Completed'),
            ('paused', 'Paused'),
            ('dropped', 'Dropped'),
            ('expired', 'Expired')
        ],
        default='active'
    )
    
    # Payment Info
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    payment_method = models.CharField(max_length=50, blank=True)
    payment_status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('completed', 'Completed'),
            ('failed', 'Failed'),
            ('refunded', 'Refunded')
        ],
        default='pending'
    )
    transaction_id = models.CharField(max_length=100, blank=True)
    payment_date = models.DateTimeField(blank=True, null=True)
    
    # Access Control
    access_type = models.CharField(
        max_length=20,
        choices=[
            ('lifetime', 'Lifetime'),
            ('limited', 'Limited'),
            ('subscription', 'Subscription')
        ],
        default='lifetime'
    )
    access_start_date = models.DateTimeField(blank=True, null=True)
    access_expiry_date = models.DateTimeField(blank=True, null=True)
    
    # Learning Stats
    total_time_spent_minutes = models.IntegerField(default=0)
    lessons_completed = models.IntegerField(default=0)
    assessments_completed = models.IntegerField(default=0)
    average_score = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'enrollments'
        unique_together = ['student', 'course']
        ordering = ['-enrollment_date']

    def __str__(self):
        return f"{self.student.user.email} - {self.course.title_th}"


class Assessment(models.Model):
    """Assessment results and scores (questions stored in Weaviate)"""
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='assessments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='assessments')
    
    assessment_type = models.CharField(
        max_length=20,
        choices=[
            ('quiz', 'Quiz'),
            ('homework', 'Homework'),
            ('midterm', 'Midterm'),
            ('final_exam', 'Final Exam'),
            ('practice', 'Practice'),
            ('mock_exam', 'Mock Exam'),
            ('assignment', 'Assignment')
        ],
        default='quiz'
    )
    
    title_th = models.CharField(max_length=255, blank=True)
    title_en = models.CharField(max_length=255, blank=True)
    
    # Results (questions stored in Weaviate, only results here)
    total_score = models.DecimalField(max_digits=5, decimal_places=2)
    max_score = models.DecimalField(max_digits=5, decimal_places=2, default=100)
    percentage_score = models.DecimalField(max_digits=5, decimal_places=2)
    passed = models.BooleanField(default=False)
    passing_score = models.DecimalField(max_digits=5, decimal_places=2, default=60)
    
    # AI Feedback (stored as JSON)
    ai_feedback = models.TextField(blank=True)
    ai_recommendations = models.TextField(blank=True)
    weak_areas = models.JSONField(default=list, blank=True)
    strong_areas = models.JSONField(default=list, blank=True)
    
    # Timing
    time_limit_minutes = models.IntegerField(blank=True, null=True)
    time_spent_minutes = models.IntegerField(default=0)
    attempt_number = models.IntegerField(default=1)
    max_attempts = models.IntegerField(default=3)
    
    started_at = models.DateTimeField(blank=True, null=True)
    submitted_at = models.DateTimeField(blank=True, null=True)
    graded_at = models.DateTimeField(blank=True, null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'assessments'
        ordering = ['-submitted_at']

    def __str__(self):
        return f"{self.student.user.email} - {self.assessment_type} - {self.percentage_score}%"


class Certificate(models.Model):
    """Course completion certificates"""
    enrollment = models.OneToOneField(Enrollment, on_delete=models.CASCADE, related_name='certificate')
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='certificates')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='certificates')
    
    certificate_number = models.CharField(max_length=50, unique=True)
    certificate_type = models.CharField(
        max_length=20,
        choices=[
            ('completion', 'Completion'),
            ('achievement', 'Achievement'),
            ('excellence', 'Excellence'),
            ('participation', 'Participation')
        ],
        default='completion'
    )
    
    issue_date = models.DateTimeField(auto_now_add=True)
    certificate_url = models.URLField(max_length=500, blank=True)
    certificate_pdf_url = models.URLField(max_length=500, blank=True)
    verification_code = models.CharField(max_length=100, unique=True)
    verification_url = models.URLField(max_length=500, blank=True)
    
    final_score = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    grade = models.CharField(max_length=10, blank=True)
    completion_time_days = models.IntegerField(blank=True, null=True)
    
    # AI Generated Summary
    ai_generated_summary = models.TextField(blank=True)
    skills_gained = models.JSONField(default=list, blank=True)
    
    is_valid = models.BooleanField(default=True)
    revoked_at = models.DateTimeField(blank=True, null=True)
    revoked_reason = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'certificates'
        ordering = ['-issue_date']

    def __str__(self):
        return f"{self.certificate_number} - {self.student.user.email}"


class Review(models.Model):
    """Course reviews and ratings"""
    student = models.ForeignKey(Student, on_delete=models.CASCADE, related_name='reviews')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='reviews')
    
    overall_rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    content_quality_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        blank=True,
        null=True
    )
    ai_teaching_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        blank=True,
        null=True
    )
    ease_of_understanding_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        blank=True,
        null=True
    )
    value_for_money_rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        blank=True,
        null=True
    )
    
    title = models.CharField(max_length=255, blank=True)
    comment = models.TextField(blank=True)
    pros = models.TextField(blank=True)
    cons = models.TextField(blank=True)
    
    is_verified_purchase = models.BooleanField(default=False)
    helpful_count = models.IntegerField(default=0)
    not_helpful_count = models.IntegerField(default=0)
    is_published = models.BooleanField(default=True)
    moderation_status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'Pending'),
            ('approved', 'Approved'),
            ('rejected', 'Rejected')
        ],
        default='pending'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'reviews'
        unique_together = ['student', 'course']
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.student.user.email} - {self.course.title_th} - {self.overall_rating}⭐"


# Keep the old Item model for backward compatibility (can be removed later)
class Item(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.name
