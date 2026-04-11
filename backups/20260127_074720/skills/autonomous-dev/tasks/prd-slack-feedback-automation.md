# PRD: Slack Feedback Automation System

## Overview

Build an autonomous Slack feedback processing system that monitors a designated Slack channel (C0A9SQX3S66), analyzes incoming messages using Claude AI, automatically implements suggested changes via the autonomous-dev agent, and creates pull requests with status updates back to Slack.

## Goals

- Automate the entire feedback-to-implementation pipeline
- Reduce manual intervention for processing user feedback
- Provide transparent, real-time status updates to stakeholders
- Enable autonomous bug fixes and feature implementations
- Track feedback processing metrics and success rates

## Non-Goals

- Multi-channel support (only C0A9SQX3S66 initially)
- Manual approval workflows (fully autonomous per specs)
- Slack bot conversation/interaction beyond status updates
- Feedback prioritization or filtering (all messages are feedback)

## User Stories

### US-001: Create SlackFeedback Database Model

**Description:** As a developer, I want a database model to track Slack feedback so that the system can persist state across processing stages.

**Acceptance Criteria:**
- [ ] Create `apps/api/src/models/slack_feedback.py` with SlackFeedback model
- [ ] Model includes: channel_id, message_ts, thread_ts, user_id, content (Text)
- [ ] Model includes: category (Enum: bug, feature, improvement)
- [ ] Model includes: status (Enum: pending, analyzing, implementing, retry, completed, failed)
- [ ] Model includes: implementation_plan (JSON), pr_url, error_message (Text), retry_count (Integer, default=0)
- [ ] Model includes: created_at, updated_at (DateTime via TimestampMixin)
- [ ] Add SlackFeedback to models __init__.py exports
- [ ] Typecheck passes
- [ ] No syntax errors

### US-002: Create Alembic Migration for SlackFeedback

**Description:** As a developer, I want a database migration for the SlackFeedback model so that the schema is properly versioned.

**Acceptance Criteria:**
- [ ] Create migration in `apps/api/alembic/versions/` with timestamp naming
- [ ] Migration creates slack_feedback table with all columns
- [ ] Unique constraint on message_ts (prevent duplicate processing)
- [ ] Index on status column for query performance
- [ ] Index on created_at for time-based queries
- [ ] Migration upgrade and downgrade functions defined
- [ ] Typecheck passes

### US-003: Create Slack Service for Fetching Messages

**Description:** As a developer, I want a service to fetch new Slack messages so that the system can retrieve unprocessed feedback.

**Acceptance Criteria:**
- [ ] Create `apps/api/src/services/slack_feedback_service.py`
- [ ] Implement `fetch_new_messages(channel_id: str, after_ts: Optional[str])` function
- [ ] Use existing SlackProvider to call conversations.history API
- [ ] Return list of messages with: text, ts, thread_ts, user
- [ ] Handle pagination (if >100 messages)
- [ ] Handle API errors gracefully with logging
- [ ] Typecheck passes
- [ ] Unit tests pass (if added)

### US-004: Create Feedback Analysis Service with Claude

**Description:** As a developer, I want to analyze feedback messages using Claude so that the system can categorize and plan implementations.

**Acceptance Criteria:**
- [ ] Add `analyze_feedback(message_content: str)` function to slack_feedback_service.py
- [ ] Use Anthropic SDK (anthropic==0.7.7) with settings.anthropic_api_key
- [ ] Prompt Claude to extract: category (bug/feature/improvement), description, expected behavior, actual behavior, affected component
- [ ] Generate detailed implementation plan with steps
- [ ] Return structured dict with all extracted data
- [ ] Handle Claude API errors with retries
- [ ] Log analysis results
- [ ] Typecheck passes

### US-005: Create Slack Response Handler Service

**Description:** As a developer, I want to post status updates to Slack so that users receive acknowledgment and progress updates.

**Acceptance Criteria:**
- [ ] Add `notify_slack(feedback_id: int, status: str, message: str)` function to slack_feedback_service.py
- [ ] Use existing SlackProvider to post messages
- [ ] Support thread replies (use thread_ts from feedback)
- [ ] Format messages with emoji status indicators (✓, 📋, ⚙️, ✅, ✗)
- [ ] Include feedback summary and relevant details
- [ ] Handle case when thread_ts is None (post to channel)
- [ ] Log notification results
- [ ] Typecheck passes

### US-006: Create Autonomous Implementation Orchestrator

**Description:** As a developer, I want to invoke the autonomous-dev agent programmatically so that feedback can be implemented automatically.

**Acceptance Criteria:**
- [ ] Add `execute_implementation(feedback_id: int)` function to slack_feedback_service.py
- [ ] Load feedback from database including implementation_plan
- [ ] Generate prompt for autonomous-dev from implementation plan
- [ ] Invoke autonomous-dev via subprocess: `subprocess.run(['claude', 'autonomous-dev', ...])`
- [ ] Capture stdout/stderr for logging
- [ ] Parse execution result (success/failure)
- [ ] Update feedback status based on result
- [ ] Increment retry_count on failure
- [ ] Typecheck passes

### US-007: Create PR Creation Service

**Description:** As a developer, I want to create pull requests after successful implementations so that changes can be reviewed and merged.

**Acceptance Criteria:**
- [ ] Add `create_pull_request(feedback_id: int, branch_name: str)` function to slack_feedback_service.py
- [ ] Use subprocess to call git commands: `git push origin <branch>`
- [ ] Use `gh pr create` command with title and body
- [ ] PR title format: "feat(slack-feedback): [US-XXX] [summary]"
- [ ] PR body includes: feedback details, implementation plan, testing instructions
- [ ] Return PR URL from GitHub CLI output
- [ ] Update feedback.pr_url in database
- [ ] Handle errors (branch doesn't exist, gh not configured)
- [ ] Typecheck passes

### US-008: Create Monitor Slack Channel Celery Task

**Description:** As a developer, I want a periodic Celery task to monitor the Slack channel so that new messages are detected automatically.

**Acceptance Criteria:**
- [ ] Create `apps/api/src/workflows/tasks/slack_feedback_tasks.py`
- [ ] Implement `monitor_slack_channel()` task with @celery_app.task decorator
- [ ] Task queries database for last processed message_ts
- [ ] Calls slack_feedback_service.fetch_new_messages(channel_id, after_ts)
- [ ] Creates SlackFeedback record for each new message (status=pending)
- [ ] Queues process_feedback task for each new message
- [ ] Prevents duplicate processing (check message_ts uniqueness)
- [ ] Logs number of new messages found
- [ ] Typecheck passes

### US-009: Create Process Feedback Celery Task

**Description:** As a developer, I want a Celery task to process individual feedback messages so that they are analyzed and implemented sequentially.

**Acceptance Criteria:**
- [ ] Add `process_feedback(feedback_id: int)` task to slack_feedback_tasks.py
- [ ] Update feedback status to "analyzing"
- [ ] Call slack_feedback_service.analyze_feedback()
- [ ] Save analysis results to feedback.implementation_plan
- [ ] Update feedback.category from analysis
- [ ] Call slack_feedback_service.notify_slack() with acknowledgment
- [ ] Update status to "implementing"
- [ ] Call slack_feedback_service.execute_implementation()
- [ ] On success: update status to "completed", create PR, send final notification
- [ ] On failure: update status to "retry" if retry_count < 2, else "failed"
- [ ] Typecheck passes

### US-010: Create Retry Failed Implementation Task

**Description:** As a developer, I want a Celery task to retry failed implementations so that temporary failures can be automatically recovered.

**Acceptance Criteria:**
- [ ] Add `retry_failed_implementation(feedback_id: int)` task to slack_feedback_tasks.py
- [ ] Check retry_count < 2 (max 2 retries total)
- [ ] Load previous error_message for context
- [ ] Regenerate implementation plan with alternative approach
- [ ] Update feedback status to "implementing"
- [ ] Call execute_implementation with retry flag
- [ ] Increment retry_count
- [ ] On success: complete as normal
- [ ] On failure: mark as "failed" if retry_count >= 2
- [ ] Notify Slack with retry status
- [ ] Typecheck passes

### US-011: Add Celery Beat Schedule for Monitor Task

**Description:** As a developer, I want the monitor task scheduled to run every 2 minutes so that feedback is processed promptly.

**Acceptance Criteria:**
- [ ] Add entry to celery_app.conf.beat_schedule in celery_app.py
- [ ] Task name: "monitor-slack-feedback-channel"
- [ ] Task: "src.workflows.tasks.slack_feedback_tasks.monitor_slack_channel"
- [ ] Schedule: 120.0 seconds (2 minutes)
- [ ] Queue: "scheduled"
- [ ] Typecheck passes
- [ ] Celery beat schedule valid

### US-012: Create Slack Feedback API Endpoints

**Description:** As a developer, I want REST API endpoints to view and manage feedback so that admins can monitor the system.

**Acceptance Criteria:**
- [ ] Create `apps/api/src/api/routes/slack_feedback.py`
- [ ] GET /api/slack-feedback - List all feedback (paginated, 20 per page)
- [ ] GET /api/slack-feedback/{id} - Get specific feedback details
- [ ] POST /api/slack-feedback/reprocess/{id} - Manually trigger reprocessing
- [ ] GET /api/slack-feedback/status - System health check (returns: pending count, processing count, success rate)
- [ ] Add route to main router in `apps/api/src/api/routes/__init__.py`
- [ ] Add authentication/authorization checks
- [ ] Typecheck passes
- [ ] Routes accessible via HTTP

### US-013: Add Slack Feedback Tasks to Celery Include

**Description:** As a developer, I want the new Celery tasks discovered by the worker so that they can be executed.

**Acceptance Criteria:**
- [ ] Add "src.workflows.tasks.slack_feedback_tasks" to celery_app include list
- [ ] Add task queue routing for slack_feedback_tasks.* to "workflows" queue
- [ ] Typecheck passes
- [ ] Celery worker discovers new tasks

### US-014: Create Environment Variables Documentation

**Description:** As a developer, I want documentation for required environment variables so that deployment is straightforward.

**Acceptance Criteria:**
- [ ] Add SLACK_BOT_TOKEN to settings.py (already exists as slack_bot_token)
- [ ] Add SLACK_FEEDBACK_CHANNEL_ID to settings.py with default "C0A9SQX3S66"
- [ ] Add AUTONOMOUS_DEV_PATH to settings.py with default "autonomous-dev"
- [ ] Update apps/api/.env.example with new variables and descriptions
- [ ] Verify existing ANTHROPIC_API_KEY is documented
- [ ] Typecheck passes

### US-015: Add Integration Tests

**Description:** As a developer, I want integration tests for the feedback processing flow so that the system is reliable.

**Acceptance Criteria:**
- [ ] Create test file: `apps/api/tests/integration/test_slack_feedback.py`
- [ ] Test: fetch_new_messages returns messages correctly
- [ ] Test: analyze_feedback returns structured data
- [ ] Test: execute_implementation handles success and failure
- [ ] Test: create_pull_request generates valid PR
- [ ] Test: monitor_slack_channel creates feedback records
- [ ] Mock Slack API and subprocess calls
- [ ] Tests pass with pytest
- [ ] Typecheck passes

## Technical Approach

### Architecture
- **Slack Integration:** Use existing SlackProvider for all Slack API calls (httpx-based)
- **AI Analysis:** Anthropic SDK with Claude Sonnet 4.5 for feedback categorization
- **Autonomous Implementation:** Subprocess calls to `claude autonomous-dev` CLI
- **Workflow Orchestration:** Celery with Redis for task queuing and scheduling
- **Database:** PostgreSQL with SQLAlchemy async ORM

### Key Design Decisions
1. **Sequential Processing:** Use Celery task chaining to process one feedback at a time
2. **Retry Strategy:** Max 2 retries with different implementation approaches
3. **Idempotency:** message_ts uniqueness ensures no duplicate processing
4. **Autonomous Mode:** No approval gates - analyze → implement → PR automatically
5. **Status Tracking:** Comprehensive status enum for monitoring and debugging

### Integration Points
- Existing SlackProvider (`src/notifications/providers/slack.py`)
- Celery app configuration (`src/workflows/celery_app.py`)
- Settings management (`src/config/settings.py`)
- Database models (`src/models/`)

### Error Handling
- Slack API failures: Log and retry on next monitor cycle
- Claude API failures: Retry with exponential backoff (3 attempts)
- Implementation failures: Automatic retry with alternative approach
- PR creation failures: Log error, mark as failed, notify Slack

## Success Metrics

- All user stories marked as complete with acceptance criteria met
- Monitor task runs successfully every 2 minutes
- Feedback messages create database records
- Claude analysis extracts structured data
- Autonomous-dev executes without manual intervention
- PRs created successfully with proper formatting
- Retry logic handles transient failures
- API endpoints return correct data
- No typecheck errors
- Integration tests pass

## Dependencies

- Story dependencies are linear (US-001 → US-002 → US-003, etc.)
- US-008 depends on US-003, US-004, US-005
- US-009 depends on US-004, US-005, US-006, US-007
- US-010 depends on US-009
- US-012 can be implemented independently after US-001
- US-015 depends on all previous stories

## Implementation Notes

- Use `httpx.AsyncClient` for all Slack API calls (pattern from SlackProvider)
- Use `anthropic.Anthropic` client (synchronous) for Claude API
- Use `subprocess.run()` for git and autonomous-dev CLI calls
- Follow existing logging patterns with `get_logger(__name__)`
- Follow existing error handling patterns with try/except and structured logging
- Use SQLAlchemy async session for all database operations
- Follow existing Celery task patterns with bind=True, retry configuration
