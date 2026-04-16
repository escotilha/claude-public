---
name: mistake_fastapi_dep_injection_order
description: FastAPI route params — injected Depends() must come before Query() params, or Python raises a SyntaxError
type: feedback
---

FastAPI route handler functions must list `Depends()` parameters **before** `Query()` / `Path()` / `Body()` parameters. Python's function signature rules require that parameters with defaults (like `Query(...)`) cannot precede parameters without defaults (injected deps), or it raises a `SyntaxError` at import time.

**Correct pattern (Contably convention):**
```python
@router.get("/endpoint")
async def handler(
    db: Annotated[AsyncSession, Depends(get_db_session)],         # deps first
    current_user: Annotated[CurrentUser, Depends(get_current_user)],
    ncm: str = Query(..., min_length=2),                           # Query params after
    regime: str = Query(default="lucro_presumido"),
) -> SomeSchema:
    ...
```

**Also:** In Contably, the correct import is `from src.api.deps import get_db_session, get_current_user, CurrentUser` — there is no `src.api.dependencies` module.

Discovered: 2026-04-16
Source: failure — Systax integration routes raised ModuleNotFoundError + SyntaxError on startup
Relevance score: 7
Use count: 1
Applied in: contably - 2026-04-16 - HELPFUL
