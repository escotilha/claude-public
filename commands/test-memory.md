---
name: test-memory
description: "Test Memory MCP server connection and create a test memory entity"
---

# Test Memory MCP

This command verifies the Memory MCP server is working correctly.

## Steps

1. **Search for existing memories**
   ```
   Use mcp__memory__search_nodes with query: ""
   ```
   This should return all existing memory entities (or an empty list if none exist).

2. **Create a test memory**
   ```
   Use mcp__memory__create_entities with:
   {
     "entities": [{
       "name": "test:memory-system-check",
       "entityType": "system-test",
       "observations": [
         "Memory MCP test created on: [current date]",
         "Test confirms: create_entities works"
       ]
     }]
   }
   ```

3. **Verify the test memory was created**
   ```
   Use mcp__memory__search_nodes with query: "test:memory-system-check"
   ```
   Should return the test entity we just created.

4. **Clean up (optional)**
   ```
   Use mcp__memory__delete_entities with:
   { "entityNames": ["test:memory-system-check"] }
   ```

## Expected Output

If Memory MCP is working:
- Step 1: Returns list of entities (may be empty)
- Step 2: Creates entity successfully
- Step 3: Returns the test entity
- Step 4: Deletes the test entity

## Troubleshooting

If tools are not available:
1. Check that `memory` server is in settings.json under `mcp.mcpServers`
2. Restart Claude Code session
3. Run `/mcp` to see connected servers

## Memory MCP Tools Reference

| Tool | Purpose |
|------|---------|
| `mcp__memory__create_entities` | Create new memory entities |
| `mcp__memory__search_nodes` | Search memories by query |
| `mcp__memory__open_nodes` | Get full details of specific entities |
| `mcp__memory__add_observations` | Add observations to existing entities |
| `mcp__memory__create_relations` | Create relationships between entities |
| `mcp__memory__delete_entities` | Delete memory entities |
