---
name: pattern_contably_integration_module_structure
description: Contably 3rd-party integration layout: integrations/{name}/{client,service,cache,schemas}.py + models/{name}.py + routes/system/{name}.py + tasks/{name}_tasks.py
type: project
---

Contably has a consistent pattern for 3rd-party service integrations (Systax, CertControl, etc.):

**Directory layout:**
```
apps/api/src/
  integrations/{name}/
    __init__.py          # exports public API
    client.py            # async HTTP client, auth (JWT/API key), retry logic
    service.py           # domain service — business logic, DB writes
    cache.py             # Redis caching (TTL, key helpers)
    schemas.py           # Pydantic request/response models (no SQLAlchemy here)
  models/{name}.py       # SQLAlchemy models for integration-specific tables
  api/routes/system/{name}.py  # FastAPI router, registered in system/__init__.py
  workflows/tasks/{name}_tasks.py  # Celery tasks: sync, warm-up, on-demand
```

**Registration checklist:**
1. Add router to `apps/api/src/api/routes/system/__init__.py`
2. Add models to `apps/api/src/models/__init__.py`
3. Add Celery tasks to `apps/api/src/workflows/celery_app.py` (autodiscover list)
4. Add config to `apps/api/src/config/settings.py`
5. Write migration for new DB tables

**Import convention:** Always import DB session and auth from `src.api.deps` (not `src.api.dependencies` — that module does not exist).

Discovered: 2026-04-16
Source: implementation — Systax fiscal integration (Contably)
Relevance score: 5
Use count: 1
Applied in: contably - 2026-04-16 - HELPFUL
