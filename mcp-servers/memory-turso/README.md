# Memory Turso MCP Server

A Turso-backed MCP Memory Server that provides a drop-in replacement for [@modelcontextprotocol/server-memory](https://www.npmjs.com/package/@modelcontextprotocol/server-memory). Instead of storing the knowledge graph in a local JSONL file, this server persists data to a Turso database with optional embedded replica support for low-latency reads.

## Features

- Full compatibility with the original server-memory tool interface
- Persistent storage in Turso (SQLite on the edge)
- Optional embedded replica for local reads with async sync
- Auto-initializes database schema on first run
- Proper foreign key relationships and indexing

## Prerequisites

1. A Turso account - [Sign up for free](https://turso.tech)
2. Node.js 18+

## Setup

### 1. Create a Turso Database

```bash
# Install the Turso CLI
brew install tursodatabase/tap/turso

# Login to Turso
turso auth login

# Create a database
turso db create claude-memory

# Get the database URL
turso db show claude-memory --url

# Create an auth token
turso db tokens create claude-memory
```

### 2. Install Dependencies

```bash
cd memory-turso
npm install
```

### 3. Build

```bash
npm run build
```

## Configuration

The server is configured via environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `TURSO_DATABASE_URL` | Yes | The Turso database URL (e.g., `libsql://your-db-name-your-org.turso.io`) |
| `TURSO_AUTH_TOKEN` | Yes* | The Turso auth token (*not required for local-only development) |
| `TURSO_LOCAL_REPLICA_PATH` | No | Path to a local SQLite file for embedded replica mode |

### Embedded Replica Mode

When `TURSO_LOCAL_REPLICA_PATH` is set, the server uses embedded replica mode:

- Reads are served from the local SQLite file (fast, no network latency)
- Writes go to both local and remote, with async sync
- Ideal for low-latency read-heavy workloads

```bash
# Example with embedded replica
export TURSO_DATABASE_URL="libsql://claude-memory-yourorg.turso.io"
export TURSO_AUTH_TOKEN="your-token"
export TURSO_LOCAL_REPLICA_PATH="/path/to/local-replica.db"
```

## Usage with Claude Desktop

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["/path/to/memory-turso/dist/index.js"],
      "env": {
        "TURSO_DATABASE_URL": "libsql://your-db-name-your-org.turso.io",
        "TURSO_AUTH_TOKEN": "your-token"
      }
    }
  }
}
```

With embedded replica:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["/path/to/memory-turso/dist/index.js"],
      "env": {
        "TURSO_DATABASE_URL": "libsql://your-db-name-your-org.turso.io",
        "TURSO_AUTH_TOKEN": "your-token",
        "TURSO_LOCAL_REPLICA_PATH": "/path/to/local-replica.db"
      }
    }
  }
}
```

## Usage with Claude Code

Add to your `.mcp.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["/path/to/memory-turso/dist/index.js"],
      "env": {
        "TURSO_DATABASE_URL": "libsql://your-db-name-your-org.turso.io",
        "TURSO_AUTH_TOKEN": "your-token"
      }
    }
  }
}
```

## Tools

This server implements all 9 tools from the original server-memory:

| Tool | Description |
|------|-------------|
| `create_entities` | Create multiple new entities in the knowledge graph |
| `create_relations` | Create relations between entities (active voice) |
| `add_observations` | Add observations to existing entities |
| `delete_entities` | Delete entities and their relations/observations |
| `delete_observations` | Delete specific observations from entities |
| `delete_relations` | Delete specific relations |
| `read_graph` | Return the entire knowledge graph |
| `search_nodes` | Search entities by query (name, type, observation content) |
| `open_nodes` | Get specific entities by name |

## Database Schema

```sql
CREATE TABLE entities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  entity_type TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE observations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (entity_name) REFERENCES entities(name) ON DELETE CASCADE
);

CREATE TABLE relations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_entity TEXT NOT NULL,
  to_entity TEXT NOT NULL,
  relation_type TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(from_entity, to_entity, relation_type)
);
```

## Development

```bash
# Watch mode for development
npm run dev

# Clean build artifacts
npm run clean

# Build for production
npm run build
```

## Migrating from server-memory

If you have existing data in the original server-memory JSONL format, you can migrate it by:

1. Reading the existing `memory.jsonl` file
2. Parsing each line as JSON
3. Using the `create_entities` and `create_relations` tools to import the data

A migration script is not included but would be straightforward to write if needed.

## License

MIT
