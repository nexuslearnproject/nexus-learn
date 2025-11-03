# Nexus Learn

A full-stack application with Django backend, Next.js frontend, and PostgreSQL database, all orchestrated with Docker Compose.

## Tech Stack

- **Backend**: Django 4.2 + Django REST Framework
- **Frontend**: Next.js 14 (React 18) with TypeScript
- **Database**: PostgreSQL 15
- **Containerization**: Docker & Docker Compose

## Prerequisites

- Docker and Docker Compose installed on your system
- Git (optional)

## Quick Start

1. **Clone the repository** (if applicable) or navigate to the project directory

2. **Create environment file**:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` if you want to change the default configuration.

3. **Start all services**:
   ```bash
   docker-compose up --build
   ```

4. **Run database migrations** (in a new terminal or after services are up):
   ```bash
   docker-compose exec backend python manage.py migrate
   ```

5. **Create a superuser** (optional, for Django admin):
   ```bash
   docker-compose exec backend python manage.py createsuperuser
   ```

6. **Access the applications**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Django Admin: http://localhost:8000/admin
   - API Health Check: http://localhost:8000/api/health/

## Project Structure

```
nexus-learn/
├── backend/              # Django backend
│   ├── config/          # Django project settings
│   ├── api/             # API app with models, views, serializers
│   ├── manage.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/            # Next.js frontend
│   ├── app/            # Next.js app directory
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml   # Docker Compose configuration
├── .env.example        # Environment variables template
└── README.md
```

## Available API Endpoints

- `GET /api/health/` - Health check endpoint
- `GET /api/items/` - List all items
- `POST /api/items/` - Create a new item
- `GET /api/items/{id}/` - Get a specific item
- `PUT /api/items/{id}/` - Update an item
- `DELETE /api/items/{id}/` - Delete an item

## Docker Commands

### Start services
```bash
docker-compose up
```

### Start services in detached mode
```bash
docker-compose up -d
```

### Rebuild and start
```bash
docker-compose up --build
```

### Stop services
```bash
docker-compose down
```

### Stop and remove volumes (clears database)
```bash
docker-compose down -v
```

### View logs
```bash
docker-compose logs -f
```

### Execute commands in containers
```bash
# Backend shell
docker-compose exec backend bash

# Database shell
docker-compose exec db psql -U nexus_user -d nexus_db

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser
```

## Development

### Backend Development

The backend code is mounted as a volume, so changes will be reflected immediately. However, you may need to restart the container for some changes (like new dependencies).

To add new Python packages:
1. Add them to `backend/requirements.txt`
2. Rebuild the container: `docker-compose up --build backend`

### Frontend Development

The frontend code is also mounted as a volume. Changes will be hot-reloaded automatically.

To add new npm packages:
1. Install them: `docker-compose exec frontend npm install <package-name>`
2. Or edit `package.json` and rebuild: `docker-compose up --build frontend`

## Environment Variables

Key environment variables (configure in `.env`):

- `POSTGRES_DB` - PostgreSQL database name
- `POSTGRES_USER` - PostgreSQL username
- `POSTGRES_PASSWORD` - PostgreSQL password
- `DJANGO_SECRET_KEY` - Django secret key (change in production!)
- `DJANGO_DEBUG` - Django debug mode (True/False)
- `NEXT_PUBLIC_API_URL` - API URL for frontend

## Troubleshooting

### Database connection issues
- Ensure the database container is healthy: `docker-compose ps`
- Check database logs: `docker-compose logs db`
- Verify environment variables in `.env`

### Port conflicts
- If ports 3000, 8000, or 5432 are already in use, modify them in `docker-compose.yml`

### Permission issues
- On Linux, you may need to adjust file permissions
- Ensure Docker has permission to access the project directory

## Production Deployment

For production deployment, you should:

1. Set `DJANGO_DEBUG=False` in `.env`
2. Generate a secure `DJANGO_SECRET_KEY`
3. Configure proper `ALLOWED_HOSTS`
4. Set up proper CORS origins
5. Use production-ready database credentials
6. Configure static file serving
7. Set up SSL/HTTPS
8. Use production Dockerfiles (multi-stage builds)
9. Set up proper logging and monitoring

## License

MIT

