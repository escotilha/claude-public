# Coding Standards

Global conventions that apply across all projects.

## Language Preferences

- Primary languages: TypeScript (primary), Python, Shell scripts
- Use TypeScript for new code unless otherwise specified
- Python for backend services, scripts, and data processing
- Shell scripts for automation and CI/CD tasks

## Deployment Workflow

When updating or deploying, complete the full workflow:

1. Check current version (`git log -1`, check package.json)
2. Pull updates (`git pull origin main`)
3. Run tests (`npm test` or `pytest`)
4. Deploy (`npm run deploy` or equivalent)
5. Confirm deployment succeeded

Never stop mid-workflow. Each step must be confirmed before proceeding.

## Installation & Setup

For installation or setup tasks, provide complete steps in one response rather than incremental guidance. Include:

- All dependencies and prerequisites
- Full command sequences
- Expected outputs or success indicators
- Troubleshooting for common issues

## Code Quality

- Write self-documenting code with clear variable and function names
- Keep functions small and focused (single responsibility)
- Avoid deep nesting - prefer early returns
- Use consistent formatting (Prettier for JS/TS, Black for Python, gofmt for Go)
- Remove dead code and unused imports before committing

## TypeScript/JavaScript

- Use TypeScript strict mode when available
- Prefer `const` over `let`, avoid `var`
- Use async/await over raw promises
- Export types alongside implementations
- Prefer named exports over default exports for better refactoring

## Error Handling

- Always handle errors explicitly, never swallow silently
- Use typed errors when possible
- Log errors with sufficient context for debugging
- Fail fast on unrecoverable errors

## Testing

- Write tests for business logic, not implementation details
- Use descriptive test names that explain the expected behavior
- Keep tests independent and deterministic
- Mock external dependencies, not internal modules

## Performance

- Avoid premature optimization
- Profile before optimizing
- Prefer readability over micro-optimizations
- Cache expensive computations when justified

## Documentation

- Document "why" not "what" - code shows what, comments explain why
- Keep README files up to date with setup instructions
- Document non-obvious architectural decisions
- Use JSDoc/docstrings for public APIs
