# Start Skill

Start all services for the Contably application in the correct order.

## Purpose

This skill starts all required services for local development of the Contably platform:

- PostgreSQL database with pgvector
- Redis for caching and sessions
- MinIO for S3-compatible object storage
- ChromaDB vector database
- Contably API (FastAPI backend)
- Contably Dashboard (React frontend)
- Celery Worker for workflow processing
- Celery Beat for scheduled tasks
- Flower for Celery monitoring

## Usage

Simply invoke this skill and it will start all services using docker-compose.

## Instructions

When this skill is invoked:

1. Check if Docker is running
2. Navigate to the project root (where docker-compose.yml is located)
3. Start all services using `docker-compose up -d`
4. Wait for services to be healthy
5. Display the status of all services
6. Provide access URLs for the key services:
   - API: http://localhost:8000
   - Dashboard: http://localhost:3000
   - MinIO Console: http://localhost:9001
   - Flower (Celery Monitor): http://localhost:5555
   - PostgreSQL: localhost:5432
   - Redis: localhost:6379

## Error Handling

If any service fails to start:

- Show the logs for the failed service using `docker-compose logs <service-name>`
- Provide troubleshooting suggestions
- Check for common issues like port conflicts or missing environment variables

## Notes

- All services are defined in docker-compose.yml
- The services include proper health checks and dependencies
- Data is persisted in Docker volumes
- The API and dashboard have hot-reload enabled for development
