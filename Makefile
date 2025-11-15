.PHONY: help install up down restart logs ps shell test migrate makemigrations clean setup init-neo4j shell-backend shell-db shell-neo4j shell-weaviate

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Environment
ENV := local

help: ## Show this help message
	@echo "$(BLUE)Nexus Learn - Makefile Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup & Installation:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '(setup|install|init)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '(up|down|restart|logs|ps)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Database:$(NC)"
	@grep -E '^[a-zAZ_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '(migrate|makemigrations|shell-db)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Testing:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '(test|coverage)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -vE '(setup|install|init|up|down|restart|logs|ps|migrate|makemigrations|test|coverage|shell-db)' | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# ============================================
# Setup & Installation
# ============================================

setup: ## Initial setup - switch to local env and install dependencies
	@echo "$(BLUE)Setting up local environment...$(NC)"
	@./scripts/switch-env.sh local
	@echo "$(GREEN)✓ Environment switched to local$(NC)"
	@echo "$(BLUE)Installing Python dependencies...$(NC)"
	@docker-compose exec -T backend pip install -r requirements.txt || echo "$(YELLOW)Backend container not running, will install on first start$(NC)"
	@echo "$(GREEN)✓ Setup complete!$(NC)"
	@echo "$(YELLOW)Run 'make up' to start services$(NC)"

install: setup ## Alias for setup

init: setup migrate init-neo4j ## Full initialization (setup + migrate + init Neo4j)
	@echo "$(GREEN)✓ Initialization complete!$(NC)"

init-neo4j: ## Initialize Neo4j knowledge base
	@echo "$(BLUE)Initializing Neo4j knowledge base...$(NC)"
	@docker-compose exec -T backend python manage.py init_neo4j || echo "$(YELLOW)Neo4j initialization skipped (service may not be ready)$(NC)"

# ============================================
# Development - Docker Compose
# ============================================

up: ## Start all services
	@echo "$(BLUE)Starting all services...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@echo "$(YELLOW)Waiting for services to be ready...$(NC)"
	@sleep 5
	@make ps

up-build: ## Start all services with rebuild
	@echo "$(BLUE)Building and starting all services...$(NC)"
	@docker-compose up -d --build
	@echo "$(GREEN)✓ Services built and started$(NC)"

down: ## Stop all services
	@echo "$(BLUE)Stopping all services...$(NC)"
	@docker-compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

down-volumes: ## Stop all services and remove volumes (WARNING: deletes data)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Services stopped and volumes removed$(NC)"; \
	fi

restart: ## Restart all services
	@echo "$(BLUE)Restarting all services...$(NC)"
	@docker-compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

restart-backend: ## Restart backend only
	@echo "$(BLUE)Restarting backend...$(NC)"
	@docker-compose restart backend
	@echo "$(GREEN)✓ Backend restarted$(NC)"

logs: ## Show logs from all services
	@docker-compose logs -f

logs-backend: ## Show backend logs
	@docker-compose logs -f backend

logs-frontend: ## Show frontend logs
	@docker-compose logs -f frontend

logs-db: ## Show database logs
	@docker-compose logs -f db

logs-neo4j: ## Show Neo4j logs
	@docker-compose logs -f neo4j

logs-weaviate: ## Show Weaviate logs
	@docker-compose logs -f weaviate

ps: ## Show status of all services
	@echo "$(BLUE)Service Status:$(NC)"
	@docker-compose ps

# ============================================
# Database Operations
# ============================================

makemigrations: ## Create database migrations
	@echo "$(BLUE)Creating migrations...$(NC)"
	@docker-compose exec -T backend python manage.py makemigrations
	@echo "$(GREEN)✓ Migrations created$(NC)"

migrate: ## Run database migrations
	@echo "$(BLUE)Running migrations...$(NC)"
	@docker-compose exec -T backend python manage.py migrate
	@echo "$(GREEN)✓ Migrations applied$(NC)"

migrate-rollback: ## Rollback last migration
	@echo "$(YELLOW)Rolling back last migration...$(NC)"
	@docker-compose exec -T backend python manage.py migrate $(APP) $(MIGRATION)

createsuperuser: ## Create Django superuser
	@echo "$(BLUE)Creating superuser...$(NC)"
	@docker-compose exec backend python manage.py createsuperuser

shell-db: ## Open PostgreSQL shell
	@echo "$(BLUE)Opening PostgreSQL shell...$(NC)"
	@docker-compose exec db psql -U $$(grep POSTGRES_USER .env | cut -d '=' -f2) -d $$(grep POSTGRES_DB .env | cut -d '=' -f2)

# ============================================
# Testing
# ============================================

test: ## Run all tests
	@echo "$(BLUE)Running tests...$(NC)"
	@docker-compose exec -T backend python manage.py test_with_migrations
	@echo "$(GREEN)✓ Tests completed$(NC)"

test-verbose: ## Run tests with verbose output
	@echo "$(BLUE)Running tests (verbose)...$(NC)"
	@docker-compose exec -T backend python manage.py test --verbosity=2

test-models: ## Run model tests only
	@echo "$(BLUE)Running model tests...$(NC)"
	@docker-compose exec -T backend python manage.py test_with_migrations api.tests.test_models

test-views: ## Run view/API tests only
	@echo "$(BLUE)Running view tests...$(NC)"
	@docker-compose exec -T backend python manage.py test api.tests.test_views

test-services: ## Run service tests only
	@echo "$(BLUE)Running service tests...$(NC)"
	@docker-compose exec -T backend python manage.py test api.tests.test_services

test-coverage: ## Run tests with coverage report
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	@docker-compose exec -T backend sh -c "coverage run --source='.' manage.py test && coverage report"

test-coverage-html: ## Generate HTML coverage report
	@echo "$(BLUE)Generating HTML coverage report...$(NC)"
	@docker-compose exec -T backend sh -c "coverage run --source='.' manage.py test && coverage html"
	@echo "$(GREEN)✓ Coverage report generated at backend/htmlcov/index.html$(NC)"

# ============================================
# Shell Access
# ============================================

shell: shell-backend ## Alias for shell-backend

shell-backend: ## Open Django shell
	@echo "$(BLUE)Opening Django shell...$(NC)"
	@docker-compose exec backend python manage.py shell

shell-neo4j: ## Open Neo4j Cypher shell
	@echo "$(BLUE)Opening Neo4j Cypher shell...$(NC)"
	@docker-compose exec neo4j cypher-shell -u neo4j -p $$(grep NEO4J_PASSWORD .env | cut -d '=' -f2)

shell-weaviate: ## Open Weaviate console (via curl)
	@echo "$(BLUE)Weaviate is accessible at: http://localhost:8080$(NC)"
	@echo "$(YELLOW)Use curl or browser to interact$(NC)"
	@echo "$(BLUE)Example: curl http://localhost:8080/v1/meta$(NC)"

# ============================================
# Environment Management
# ============================================

env-local: ## Switch to local environment
	@./scripts/switch-env.sh local

env-qa: ## Switch to QA environment
	@./scripts/switch-env.sh qa

env-staging: ## Switch to staging environment
	@./scripts/switch-env.sh staging

env-production: ## Switch to production environment
	@./scripts/switch-env.sh production

# ============================================
# Cleanup & Maintenance
# ============================================

clean: ## Clean up Docker resources (containers, networks)
	@echo "$(BLUE)Cleaning up Docker resources...$(NC)"
	@docker-compose down
	@docker system prune -f
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-all: ## Clean everything including volumes (WARNING: deletes data)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		docker system prune -af --volumes; \
		echo "$(GREEN)✓ Everything cleaned$(NC)"; \
	fi

clean-pyc: ## Remove Python cache files
	@echo "$(BLUE)Removing Python cache files...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -r {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Python cache cleaned$(NC)"

# ============================================
# Quick Development Workflows
# ============================================

dev: up migrate ## Start development environment (up + migrate)
	@echo "$(GREEN)✓ Development environment ready!$(NC)"
	@echo "$(BLUE)Frontend: http://localhost:3000$(NC)"
	@echo "$(BLUE)Backend: http://localhost:8000$(NC)"
	@echo "$(BLUE)Neo4j Browser: http://localhost:7474$(NC)"
	@echo "$(BLUE)Weaviate: http://localhost:8080$(NC)"

dev-full: dev init-neo4j ## Full dev setup (dev + init Neo4j)
	@echo "$(GREEN)✓ Full development environment ready!$(NC)"

rebuild: down up-build migrate ## Rebuild and restart everything
	@echo "$(GREEN)✓ Rebuild complete!$(NC)"

# ============================================
# Health Checks
# ============================================

health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo ""
	@echo "$(YELLOW)Backend API:$(NC)"
	@curl -s http://localhost:8000/api/health/ | python -m json.tool || echo "$(RED)✗ Backend not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Frontend:$(NC)"
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|302" && echo "$(GREEN)✓ Frontend OK$(NC)" || echo "$(RED)✗ Frontend not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Neo4j:$(NC)"
	@curl -s http://localhost:7474 | grep -q "Neo4j" && echo "$(GREEN)✓ Neo4j OK$(NC)" || echo "$(RED)✗ Neo4j not responding$(NC)"
	@echo ""
	@echo "$(YELLOW)Weaviate:$(NC)"
	@curl -s http://localhost:8080/v1/meta | python -m json.tool > /dev/null && echo "$(GREEN)✓ Weaviate OK$(NC)" || echo "$(RED)✗ Weaviate not responding$(NC)"

# ============================================
# Database Backup & Restore
# ============================================

backup-db: ## Backup PostgreSQL database
	@echo "$(BLUE)Backing up database...$(NC)"
	@mkdir -p backups
	@docker-compose exec -T db pg_dump -U $$(grep POSTGRES_USER .env | cut -d '=' -f2) $$(grep POSTGRES_DB .env | cut -d '=' -f2) > backups/db_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Database backed up to backups/$(NC)"

restore-db: ## Restore PostgreSQL database (requires BACKUP_FILE variable)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Error: BACKUP_FILE not specified$(NC)"; \
		echo "Usage: make restore-db BACKUP_FILE=backups/db_backup_20241114_120000.sql"; \
		exit 1; \
	fi
	@echo "$(BLUE)Restoring database from $(BACKUP_FILE)...$(NC)"
	@docker-compose exec -T db psql -U $$(grep POSTGRES_USER .env | cut -d '=' -f2) $$(grep POSTGRES_DB .env | cut -d '=' -f2) < $(BACKUP_FILE)
	@echo "$(GREEN)✓ Database restored$(NC)"

# ============================================
# Information
# ============================================

info: ## Show project information
	@echo "$(BLUE)=== Nexus Learn Project Info ===$(NC)"
	@echo ""
	@echo "$(GREEN)Current Environment:$(NC)"
	@grep "^ENVIRONMENT=" .env 2>/dev/null || echo "  Not set"
	@echo ""
	@echo "$(GREEN)Service URLs:$(NC)"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8000"
	@echo "  Neo4j:     http://localhost:7474"
	@echo "  Weaviate:  http://localhost:8080"
	@echo ""
	@echo "$(GREEN)Database:$(NC)"
	@grep "^POSTGRES_DB=" .env 2>/dev/null | cut -d '=' -f2 || echo "  Not configured"
	@echo ""
	@make ps

