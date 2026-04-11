import { getDb, syncReplica } from "./db.js";
import {
  Entity,
  Relation,
  KnowledgeGraph,
  ObservationInput,
  ObservationResult,
  ObservationDeletion,
} from "./types.js";

export class KnowledgeGraphManager {
  private async syncIfNeeded(): Promise<void> {
    await syncReplica();
  }

  async createEntities(entities: Entity[]): Promise<Entity[]> {
    const db = getDb();
    const newEntities: Entity[] = [];

    for (const entity of entities) {
      try {
        // Try to insert the entity
        await db.execute({
          sql: "INSERT INTO entities (name, entity_type) VALUES (?, ?)",
          args: [entity.name, entity.entityType],
        });

        // Insert observations for this entity
        for (const observation of entity.observations) {
          await db.execute({
            sql: "INSERT INTO observations (entity_name, content) VALUES (?, ?)",
            args: [entity.name, observation],
          });
        }

        newEntities.push(entity);
      } catch (error) {
        // Entity already exists, skip it (matches original behavior)
        if (
          error instanceof Error &&
          error.message.includes("UNIQUE constraint failed")
        ) {
          continue;
        }
        throw error;
      }
    }

    await this.syncIfNeeded();
    return newEntities;
  }

  async createRelations(relations: Relation[]): Promise<Relation[]> {
    const db = getDb();
    const newRelations: Relation[] = [];

    for (const relation of relations) {
      try {
        await db.execute({
          sql: "INSERT INTO relations (from_entity, to_entity, relation_type) VALUES (?, ?, ?)",
          args: [relation.from, relation.to, relation.relationType],
        });
        newRelations.push(relation);
      } catch (error) {
        // Relation already exists, skip it (matches original behavior)
        if (
          error instanceof Error &&
          error.message.includes("UNIQUE constraint failed")
        ) {
          continue;
        }
        throw error;
      }
    }

    await this.syncIfNeeded();
    return newRelations;
  }

  async addObservations(
    observations: ObservationInput[]
  ): Promise<ObservationResult[]> {
    const db = getDb();
    const results: ObservationResult[] = [];

    for (const obs of observations) {
      // Check if entity exists
      const entityResult = await db.execute({
        sql: "SELECT name FROM entities WHERE name = ?",
        args: [obs.entityName],
      });

      if (entityResult.rows.length === 0) {
        throw new Error(`Entity with name ${obs.entityName} not found`);
      }

      // Get existing observations for this entity
      const existingResult = await db.execute({
        sql: "SELECT content FROM observations WHERE entity_name = ?",
        args: [obs.entityName],
      });

      const existingObservations = new Set(
        existingResult.rows.map((row) => row.content as string)
      );

      const addedObservations: string[] = [];

      // Add only new observations
      for (const content of obs.contents) {
        if (!existingObservations.has(content)) {
          await db.execute({
            sql: "INSERT INTO observations (entity_name, content) VALUES (?, ?)",
            args: [obs.entityName, content],
          });
          addedObservations.push(content);
        }
      }

      results.push({
        entityName: obs.entityName,
        addedObservations,
      });
    }

    await this.syncIfNeeded();
    return results;
  }

  async deleteEntities(entityNames: string[]): Promise<void> {
    const db = getDb();

    for (const name of entityNames) {
      // Delete observations for this entity
      await db.execute({
        sql: "DELETE FROM observations WHERE entity_name = ?",
        args: [name],
      });

      // Delete relations involving this entity
      await db.execute({
        sql: "DELETE FROM relations WHERE from_entity = ? OR to_entity = ?",
        args: [name, name],
      });

      // Delete the entity itself
      await db.execute({
        sql: "DELETE FROM entities WHERE name = ?",
        args: [name],
      });
    }

    await this.syncIfNeeded();
  }

  async deleteObservations(deletions: ObservationDeletion[]): Promise<void> {
    const db = getDb();

    for (const deletion of deletions) {
      for (const observation of deletion.observations) {
        await db.execute({
          sql: "DELETE FROM observations WHERE entity_name = ? AND content = ?",
          args: [deletion.entityName, observation],
        });
      }
    }

    await this.syncIfNeeded();
  }

  async deleteRelations(relations: Relation[]): Promise<void> {
    const db = getDb();

    for (const relation of relations) {
      await db.execute({
        sql: "DELETE FROM relations WHERE from_entity = ? AND to_entity = ? AND relation_type = ?",
        args: [relation.from, relation.to, relation.relationType],
      });
    }

    await this.syncIfNeeded();
  }

  async readGraph(): Promise<KnowledgeGraph> {
    const db = getDb();

    // Get all entities
    const entitiesResult = await db.execute(
      "SELECT name, entity_type FROM entities"
    );

    // Get all observations
    const observationsResult = await db.execute(
      "SELECT entity_name, content FROM observations"
    );

    // Get all relations
    const relationsResult = await db.execute(
      "SELECT from_entity, to_entity, relation_type FROM relations"
    );

    // Build observations map
    const observationsMap = new Map<string, string[]>();
    for (const row of observationsResult.rows) {
      const entityName = row.entity_name as string;
      const content = row.content as string;
      if (!observationsMap.has(entityName)) {
        observationsMap.set(entityName, []);
      }
      observationsMap.get(entityName)!.push(content);
    }

    // Build entities array
    const entities: Entity[] = entitiesResult.rows.map((row) => ({
      name: row.name as string,
      entityType: row.entity_type as string,
      observations: observationsMap.get(row.name as string) || [],
    }));

    // Build relations array
    const relations: Relation[] = relationsResult.rows.map((row) => ({
      from: row.from_entity as string,
      to: row.to_entity as string,
      relationType: row.relation_type as string,
    }));

    return { entities, relations };
  }

  async searchNodes(query: string): Promise<KnowledgeGraph> {
    const db = getDb();
    const lowerQuery = `%${query.toLowerCase()}%`;

    // Find entities matching the query in name, type, or observations
    const entityNamesResult = await db.execute({
      sql: `
        SELECT DISTINCT e.name
        FROM entities e
        LEFT JOIN observations o ON e.name = o.entity_name
        WHERE LOWER(e.name) LIKE ?
           OR LOWER(e.entity_type) LIKE ?
           OR LOWER(o.content) LIKE ?
      `,
      args: [lowerQuery, lowerQuery, lowerQuery],
    });

    const matchingNames = entityNamesResult.rows.map(
      (row) => row.name as string
    );

    if (matchingNames.length === 0) {
      return { entities: [], relations: [] };
    }

    // Get full entity data for matching entities
    const placeholders = matchingNames.map(() => "?").join(",");

    const entitiesResult = await db.execute({
      sql: `SELECT name, entity_type FROM entities WHERE name IN (${placeholders})`,
      args: matchingNames,
    });

    const observationsResult = await db.execute({
      sql: `SELECT entity_name, content FROM observations WHERE entity_name IN (${placeholders})`,
      args: matchingNames,
    });

    // Only include relations between matching entities
    const relationsResult = await db.execute({
      sql: `SELECT from_entity, to_entity, relation_type FROM relations WHERE from_entity IN (${placeholders}) AND to_entity IN (${placeholders})`,
      args: [...matchingNames, ...matchingNames],
    });

    // Build observations map
    const observationsMap = new Map<string, string[]>();
    for (const row of observationsResult.rows) {
      const entityName = row.entity_name as string;
      const content = row.content as string;
      if (!observationsMap.has(entityName)) {
        observationsMap.set(entityName, []);
      }
      observationsMap.get(entityName)!.push(content);
    }

    // Build entities array
    const entities: Entity[] = entitiesResult.rows.map((row) => ({
      name: row.name as string,
      entityType: row.entity_type as string,
      observations: observationsMap.get(row.name as string) || [],
    }));

    // Build relations array
    const relations: Relation[] = relationsResult.rows.map((row) => ({
      from: row.from_entity as string,
      to: row.to_entity as string,
      relationType: row.relation_type as string,
    }));

    return { entities, relations };
  }

  async openNodes(names: string[]): Promise<KnowledgeGraph> {
    const db = getDb();

    if (names.length === 0) {
      return { entities: [], relations: [] };
    }

    const placeholders = names.map(() => "?").join(",");

    // Get entities by name
    const entitiesResult = await db.execute({
      sql: `SELECT name, entity_type FROM entities WHERE name IN (${placeholders})`,
      args: names,
    });

    // Get observations for these entities
    const observationsResult = await db.execute({
      sql: `SELECT entity_name, content FROM observations WHERE entity_name IN (${placeholders})`,
      args: names,
    });

    // Get relations between these entities only
    const relationsResult = await db.execute({
      sql: `SELECT from_entity, to_entity, relation_type FROM relations WHERE from_entity IN (${placeholders}) AND to_entity IN (${placeholders})`,
      args: [...names, ...names],
    });

    // Build observations map
    const observationsMap = new Map<string, string[]>();
    for (const row of observationsResult.rows) {
      const entityName = row.entity_name as string;
      const content = row.content as string;
      if (!observationsMap.has(entityName)) {
        observationsMap.set(entityName, []);
      }
      observationsMap.get(entityName)!.push(content);
    }

    // Build entities array
    const entities: Entity[] = entitiesResult.rows.map((row) => ({
      name: row.name as string,
      entityType: row.entity_type as string,
      observations: observationsMap.get(row.name as string) || [],
    }));

    // Build relations array
    const relations: Relation[] = relationsResult.rows.map((row) => ({
      from: row.from_entity as string,
      to: row.to_entity as string,
      relationType: row.relation_type as string,
    }));

    return { entities, relations };
  }
}
