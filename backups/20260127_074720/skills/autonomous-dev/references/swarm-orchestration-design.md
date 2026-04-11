# Swarm Orchestration Design Document

## Overview

Swarm mode enables true multi-agent orchestration using Claude Code's TeammateTool. Unlike parallel delegation (which uses short-lived Task subagents), swarm mode creates persistent worker agents that:

- Join a named team
- Communicate via inbox messaging
- Self-organize by claiming tasks from a shared board
- Maintain fresh context per worker (no token bloat)
- Run visibly in tmux panes (optional)

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AUTONOMOUS-DEV                              │
│                                                                      │
│  Phase 1-2: PRD Generation (unchanged)                              │
│                                                                      │
│  Phase 3: Execution Mode Selection                                   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  if (swarm.enabled)        → Phase 3-swarm                   │   │
│  │  else if (parallel.enabled) → Phase 3-parallel               │   │
│  │  else if (delegation.enabled) → Phase 3 with delegation      │   │
│  │  else                       → Phase 3 sequential             │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  Phase 3-swarm: Swarm Orchestration                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  1. Initialize team (TeammateTool.spawnTeam)                 │   │
│  │  2. Create all tasks on shared board (TaskCreate)            │   │
│  │  3. Spawn specialist workers (Task with team_name)           │   │
│  │  4. Leader monitoring loop (inbox polling)                   │   │
│  │  5. Handle completions, failures, escalations                │   │
│  │  6. Graceful shutdown (TeammateTool.cleanup)                 │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## TeammateTool Operations

### Core Operations

| Operation | Purpose | When to Use |
|-----------|---------|-------------|
| `spawnTeam` | Create team infrastructure | Once at swarm start |
| `write` | Send message to specific teammate | Task completion, help requests |
| `broadcast` | Message all teammates | Shutdown, urgent announcements |
| `requestShutdown` | Ask worker to stop | Graceful shutdown |
| `approveShutdown` | Worker acknowledges shutdown | Worker response |
| `cleanup` | Remove team resources | End of swarm |

### Message Types

```typescript
type Message = {
  type: 'task_completed' | 'task_failed' | 'idle_notification' |
        'help_request' | 'shutdown_request' | 'shutdown_approved';
  from: string;
  timestamp: string;
  payload: Record<string, any>;
};

// Task completion message
interface TaskCompletedMessage {
  type: 'task_completed';
  taskId: string;
  result: 'SUCCESS' | 'FAILURE';
  filesChanged: string[];
  verification: {
    typecheck: 'PASS' | 'FAIL';
    test: 'PASS' | 'FAIL';
    lint: 'PASS' | 'FAIL';
  };
  notes: string;
  learnings: string;
}

// Help request message
interface HelpRequestMessage {
  type: 'help_request';
  taskId: string;
  attempts: number;
  lastError: string;
  context: string;
}

// Idle notification
interface IdleNotificationMessage {
  type: 'idle_notification';
  worker: string;
  completedCount: number;
}
```

## Worker Lifecycle

### State Machine

```
┌─────────┐    spawn     ┌─────────┐    claim task   ┌───────────┐
│  INIT   │─────────────>│  IDLE   │─────────────────>│  WORKING  │
└─────────┘              └─────────┘                  └───────────┘
                              ^                             │
                              │                             │
                              │     complete/fail           │
                              └─────────────────────────────┘
                              │
                              │ shutdown request
                              v
                         ┌──────────┐
                         │ SHUTDOWN │
                         └──────────┘
```

### Worker Main Loop

```javascript
async function workerMainLoop(workerType, teamName) {
  let running = true;

  while (running) {
    // 1. Check for shutdown requests
    const messages = await checkInbox();
    if (messages.some(m => m.type === 'shutdown_request')) {
      await acknowledgeShutdown(teamName);
      running = false;
      continue;
    }

    // 2. Find available task matching specialty
    const tasks = await TaskList();
    const myTask = tasks.find(t =>
      t.status === 'pending' &&
      !t.owner &&
      !isBlocked(t) &&
      matchesSpecialty(t, workerType)
    );

    if (!myTask) {
      // No matching tasks - notify leader and wait
      await notifyIdle(teamName, workerType);
      await sleep(5000);
      continue;
    }

    // 3. Claim the task
    await TaskUpdate({
      taskId: myTask.id,
      status: 'in_progress',
      owner: `${workerType}-worker`
    });

    // 4. Implement the story
    const result = await implementStory(myTask);

    // 5. Report result
    await TaskUpdate({
      taskId: myTask.id,
      status: result.success ? 'completed' : 'pending',
      owner: result.success ? `${workerType}-worker` : null
    });

    await reportToLeader(teamName, {
      type: result.success ? 'task_completed' : 'task_failed',
      taskId: myTask.id,
      ...result
    });

    // 6. Commit if successful
    if (result.success) {
      await commitChanges(myTask);
    }
  }
}
```

## Leader Responsibilities

### Task Board Management

```javascript
// Create tasks with dependencies
async function initializeTaskBoard(prd) {
  const taskIdMap = {};

  // First pass: create all tasks
  for (const story of prd.userStories) {
    const taskId = await TaskCreate({
      subject: `${story.id}: ${story.title}`,
      description: formatTaskDescription(story),
      metadata: {
        storyId: story.id,
        type: story.detectedType,
        complexity: story.complexity
      }
    });
    taskIdMap[story.id] = taskId;
  }

  // Second pass: set up dependencies
  for (const story of prd.userStories) {
    if (story.dependsOn?.length > 0) {
      await TaskUpdate({
        taskId: taskIdMap[story.id],
        addBlockedBy: story.dependsOn.map(id => taskIdMap[id])
      });
    }
  }

  return taskIdMap;
}
```

### Inbox Monitoring

```javascript
async function monitorInboxes(teamName, prd) {
  const pollInterval = prd.swarm.coordination.inboxPollingInterval;

  while (hasActiveTasks()) {
    // Read leader inbox
    const messages = await readInbox(teamName, 'leader');

    for (const message of messages) {
      switch (message.type) {
        case 'task_completed':
          await handleCompletion(message, prd);
          break;

        case 'task_failed':
          await handleFailure(message, prd);
          break;

        case 'idle_notification':
          trackIdleWorker(message.worker);
          break;

        case 'help_request':
          await escalateToUser(message);
          break;
      }
    }

    // Check for stalled workers
    await checkWorkerHealth(teamName);

    await sleep(pollInterval);
  }
}
```

### Worker Health Monitoring

```javascript
async function checkWorkerHealth(teamName) {
  const workers = getSpawnedWorkers();
  const now = Date.now();

  for (const worker of workers) {
    const lastActivity = worker.lastActivityTime;
    const timeout = prd.swarm.workers.workerTimeout;

    if (now - lastActivity > timeout) {
      console.log(`Worker ${worker.name} appears stalled`);

      // 1. Release any tasks it owns
      const tasks = await TaskList();
      const workerTasks = tasks.filter(t => t.owner === worker.name);

      for (const task of workerTasks) {
        await TaskUpdate({
          taskId: task.id,
          status: 'pending',
          owner: null
        });
      }

      // 2. Respawn the worker
      await respawnWorker(worker.type, teamName);
    }
  }
}
```

## Spawn Backends

### Auto-Detection

```javascript
function selectSpawnBackend(config) {
  if (config.spawnBackend !== 'auto') {
    return config.spawnBackend;
  }

  // Check environment
  if (process.env.TMUX) {
    return 'tmux';  // In tmux session, use panes
  }

  if (process.platform === 'darwin' && hasITerm2()) {
    return 'iterm2';  // macOS with iTerm2
  }

  return 'in-process';  // Default: hidden
}
```

### Backend Characteristics

| Backend | Visibility | Persistence | Best For |
|---------|------------|-------------|----------|
| `in-process` | Hidden | Session | Production, CI/CD |
| `tmux` | Visible panes | Survives disconnect | Development, debugging |
| `iterm2` | Visible tabs | macOS only | macOS development |

### tmux Layout

```
┌─────────────────────────────────────────────────────────────┐
│                        LEADER                                │
│  [Monitoring task board, processing inbox messages]          │
├─────────────────────┬───────────────────┬───────────────────┤
│  frontend-worker    │   api-worker      │  database-worker  │
│                     │                   │                   │
│  Implementing       │   Idle            │  Running          │
│  US-003...          │                   │  migration...     │
│                     │                   │                   │
└─────────────────────┴───────────────────┴───────────────────┘
```

## Metrics & Observability

### Swarm Metrics Schema

```typescript
interface SwarmMetrics {
  // Execution stats
  totalBatches: number;          // Number of swarm runs
  workerSpawns: number;          // Total workers spawned (including respawns)
  messagesExchanged: number;     // Total inbox messages

  // Performance
  avgBatchDuration: number;      // Average time per swarm run (ms)
  speedupVsSequential: number;   // Calculated speedup factor

  // Per-worker breakdown
  workerStats: {
    [workerName: string]: {
      completed: number;
      failed: number;
      avgTaskDuration: number;
      respawnCount: number;
    }
  };

  // Timing
  startTime: string | null;
  endTime: string | null;
}
```

### Calculating Speedup

```javascript
function calculateSpeedup(prd, actualDuration) {
  // Estimate sequential time based on complexity
  const totalComplexity = prd.userStories.reduce((sum, s) => sum + (s.complexity || 4), 0);
  const estimatedSequentialMinutes = totalComplexity * 0.75; // ~45 sec per complexity point

  // Actual swarm duration in minutes
  const actualMinutes = actualDuration / 60000;

  return (estimatedSequentialMinutes / actualMinutes).toFixed(2);
}
```

## Error Handling

### Failure Scenarios

| Scenario | Detection | Recovery |
|----------|-----------|----------|
| Worker crash | Timeout, no heartbeat | Release tasks, respawn worker |
| Task fails 3x | Attempt counter | Escalate to leader/user |
| All workers idle | Idle notification count | Rebalance or complete |
| Circular dependency | Blocked forever | Detect and warn user |
| Team already exists | spawnTeam error | Cleanup and retry |

### Graceful Degradation

```javascript
async function handleSwarmFailure(error, prd) {
  console.error('Swarm mode failed:', error.message);

  // 1. Attempt cleanup
  try {
    await TeammateTool({ operation: 'cleanup', team_name: prd.swarm.teamName });
  } catch (e) {
    console.warn('Cleanup failed:', e.message);
  }

  // 2. Fall back to parallel mode
  if (prd.delegation?.parallel?.enabled) {
    console.log('Falling back to parallel mode...');
    return runParallelMode(prd);
  }

  // 3. Fall back to sequential
  console.log('Falling back to sequential mode...');
  return runSequentialMode(prd);
}
```

## Comparison with Alternatives

### Swarm vs Parallel vs Sequential

| Aspect | Sequential | Parallel | Swarm |
|--------|------------|----------|-------|
| **Agents** | 1 | N (short-lived) | N (persistent) |
| **Communication** | None | Return values | Inbox messages |
| **Task assignment** | Explicit | Batch | Self-claimed |
| **Context per task** | Accumulated | Fresh | Fresh |
| **Visibility** | In terminal | Hidden | tmux panes |
| **Coordination** | Manual | Leader batches | Task board |
| **Failure recovery** | Manual retry | Fallback | Auto-respawn |
| **Best for** | Small features | 2-5 parallel | 10+ stories |

### When Swarm Wins

1. **Large PRDs (10+ stories)** - Coordination overhead amortized
2. **Multi-layer features** - Specialists work independently
3. **Development/debugging** - Visible workers in tmux
4. **Long-running features** - Workers can be monitored/respawned

### When Parallel Wins

1. **Medium features (3-8 stories)** - Less overhead
2. **CI/CD environments** - No tmux needed
3. **Tightly coupled stories** - More control over execution order
4. **Quick iterations** - Faster setup/teardown

## Security Considerations

### Team Isolation

- Each team has isolated inboxes
- Workers can only message within their team
- Task board is team-scoped

### Resource Limits

```javascript
const LIMITS = {
  maxWorkers: 10,           // Per team
  maxTeams: 5,              // Per user
  workerTimeout: 600000,    // 10 minutes
  maxTasksPerBoard: 100,    // Per team
  inboxRetention: 3600000   // 1 hour
};
```

### Secrets Handling

- Workers inherit environment variables
- Secrets should be in env, not in prompts
- Task descriptions should not contain credentials

## Future Enhancements

### Planned

1. **Worker specialization learning** - Track which workers perform best on which task types
2. **Dynamic worker scaling** - Spawn more workers for large backlogs
3. **Cross-team coordination** - Workers from different features collaborate
4. **Persistent worker pools** - Reuse workers across features

### Experimental

1. **LLM-as-scheduler** - Use Claude to optimize task assignment
2. **Visual dashboard** - Web UI for swarm monitoring
3. **Distributed swarm** - Workers on different machines
