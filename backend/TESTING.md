# Testing Guide

## วิธีรัน Tests

### 1. รัน Tests ทั้งหมด

```bash
# ใน Docker container
docker-compose exec backend python manage.py test

# หรือจาก host machine (ถ้า Django ติดตั้งแล้ว)
cd backend
python manage.py test
```

### 2. รัน Tests เฉพาะ App

```bash
# Test เฉพาะ api app
docker-compose exec backend python manage.py test api

# Test เฉพาะ test file
docker-compose exec backend python manage.py test api.tests.test_models

# Test เฉพาะ test class
docker-compose exec backend python manage.py test api.tests.test_models.UserModelTest

# Test เฉพาะ test method
docker-compose exec backend python manage.py test api.tests.test_models.UserModelTest.test_user_creation
```

### 3. รัน Tests พร้อม Coverage

```bash
# ติดตั้ง coverage (ถ้ายังไม่มี)
docker-compose exec backend pip install coverage

# รัน tests พร้อม coverage
docker-compose exec backend coverage run --source='.' manage.py test

# ดู coverage report
docker-compose exec backend coverage report

# สร้าง HTML report
docker-compose exec backend coverage html
# เปิดไฟล์ htmlcov/index.html ใน browser
```

### 4. รัน Tests แบบ Verbose

```bash
# แสดง output แบบละเอียด
docker-compose exec backend python manage.py test --verbosity=2

# แสดง output แบบละเอียดมาก
docker-compose exec backend python manage.py test --verbosity=3
```

### 5. รัน Tests แบบ Keep Test Database

```bash
# เก็บ test database ไว้ (ไม่ลบหลัง test)
docker-compose exec backend python manage.py test --keepdb
```

### 6. รัน Tests แบบ Parallel

```bash
# รัน tests แบบ parallel (เร็วกว่า)
docker-compose exec backend python manage.py test --parallel
```

## Test Structure

```
backend/
├── api/
│   ├── tests/
│   │   ├── __init__.py
│   │   ├── test_models.py      # Test models
│   │   ├── test_views.py       # Test API endpoints
│   │   └── test_services.py    # Test services
```

## Test Categories

### 1. Model Tests (`test_models.py`)
- Test การสร้าง models
- Test relationships
- Test validations
- Test methods

### 2. View Tests (`test_views.py`)
- Test API endpoints
- Test authentication
- Test permissions
- Test response formats

### 3. Service Tests (`test_services.py`)
- Test business logic
- Test external service integrations
- Test error handling

## Running Specific Tests

### Test Models Only
```bash
docker-compose exec backend python manage.py test api.tests.test_models
```

### Test Views Only
```bash
docker-compose exec backend python manage.py test api.tests.test_views
```

### Test Services Only
```bash
docker-compose exec backend python manage.py test api.tests.test_services
```

## Test Database

Django จะสร้าง test database อัตโนมัติเมื่อรัน tests:
- Database name: `test_<DATABASE_NAME>`
- จะถูกลบอัตโนมัติหลัง tests เสร็จ (ยกเว้นใช้ `--keepdb`)

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          docker-compose up -d db neo4j weaviate
          docker-compose exec -T backend python manage.py test
```

## Common Test Commands

```bash
# Quick test run
docker-compose exec backend python manage.py test

# Full test with coverage
docker-compose exec backend coverage run --source='.' manage.py test && coverage report

# Test specific feature
docker-compose exec backend python manage.py test api.tests.test_models.CourseModelTest

# Test with verbose output
docker-compose exec backend python manage.py test --verbosity=2

# Keep test database for debugging
docker-compose exec backend python manage.py test --keepdb
```

## Troubleshooting

### Tests fail with database errors
```bash
# Recreate test database
docker-compose exec backend python manage.py test --keepdb
```

### Tests fail with connection errors
```bash
# Make sure services are running
docker-compose ps

# Start required services
docker-compose up -d db neo4j weaviate
```

### Import errors in tests
```bash
# Check Python path
docker-compose exec backend python -c "import sys; print(sys.path)"

# Make sure you're in the right directory
docker-compose exec backend pwd
```

## Best Practices

1. **Write tests for new features** - ทุก feature ใหม่ควรมี tests
2. **Test edge cases** - Test กรณีผิดปกติด้วย
3. **Use descriptive test names** - ชื่อ test ควรบอกว่า test อะไร
4. **Keep tests fast** - Tests ควรรันเร็ว
5. **Mock external services** - Mock services ภายนอกใน tests
6. **Test one thing at a time** - แต่ละ test ควร test แค่สิ่งเดียว

## Example Test Output

```
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
...
----------------------------------------------------------------------
Ran 15 tests in 2.345s

OK
Destroying test database for alias 'default'...
```

