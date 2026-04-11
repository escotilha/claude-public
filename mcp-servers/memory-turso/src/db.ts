import { createClient, Client } from "@libsql/client";

export interface DbConfig {
  url: string;
  authToken?: string;
  localReplicaPath?: string;
}

let db: Client | null = null;

export function getDbConfig(): DbConfig {
  const url = process.env.TURSO_DATABASE_URL;
  if (!url) {
    throw new Error("TURSO_DATABASE_URL environment variable is required");
  }

  return {
    url,
    authToken: process.env.TURSO_AUTH_TOKEN,
    localReplicaPath: process.env.TURSO_LOCAL_REPLICA_PATH,
  };
}

export async function initializeDb(): Promise<Client> {
  if (db) {
    return db;
  }

  const config = getDbConfig();

  if (config.localReplicaPath) {
    // Embedded replica mode: local SQLite file with sync to Turso
    db = createClient({
      url: `file:${config.localReplicaPath}`,
      syncUrl: config.url,
      authToken: config.authToken,
    });

    // Initial sync from remote
    await db.sync();
  } else {
    // Direct connection to Turso
    db = createClient({
      url: config.url,
      authToken: config.authToken,
    });
  }

  // Initialize schema
  await initializeSchema(db);

  return db;
}

export function getDb(): Client {
  if (!db) {
    throw new Error("Database not initialized. Call initializeDb() first.");
  }
  return db;
}

async function initializeSchema(client: Client): Promise<void> {
  await client.executeMultiple(`
    CREATE TABLE IF NOT EXISTS entities (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL,
      entity_type TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS observations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity_name TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (entity_name) REFERENCES entities(name) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS relations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      from_entity TEXT NOT NULL,
      to_entity TEXT NOT NULL,
      relation_type TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(from_entity, to_entity, relation_type)
    );

    CREATE INDEX IF NOT EXISTS idx_observations_entity_name ON observations(entity_name);
    CREATE INDEX IF NOT EXISTS idx_relations_from ON relations(from_entity);
    CREATE INDEX IF NOT EXISTS idx_relations_to ON relations(to_entity);
  `);
}

export async function syncReplica(): Promise<void> {
  if (db && process.env.TURSO_LOCAL_REPLICA_PATH) {
    await db.sync();
  }
}

export async function closeDb(): Promise<void> {
  if (db) {
    db.close();
    db = null;
  }
}
