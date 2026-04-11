export interface Entity {
  name: string;
  entityType: string;
  observations: string[];
}

export interface Relation {
  from: string;
  to: string;
  relationType: string;
}

export interface KnowledgeGraph {
  entities: Entity[];
  relations: Relation[];
}

export interface ObservationInput {
  entityName: string;
  contents: string[];
}

export interface ObservationResult {
  entityName: string;
  addedObservations: string[];
}

export interface ObservationDeletion {
  entityName: string;
  observations: string[];
}
