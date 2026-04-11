import { Entity, Relation, KnowledgeGraph, ObservationInput, ObservationResult, ObservationDeletion } from "./types.js";
export declare class KnowledgeGraphManager {
    private syncIfNeeded;
    createEntities(entities: Entity[]): Promise<Entity[]>;
    createRelations(relations: Relation[]): Promise<Relation[]>;
    addObservations(observations: ObservationInput[]): Promise<ObservationResult[]>;
    deleteEntities(entityNames: string[]): Promise<void>;
    deleteObservations(deletions: ObservationDeletion[]): Promise<void>;
    deleteRelations(relations: Relation[]): Promise<void>;
    readGraph(): Promise<KnowledgeGraph>;
    searchNodes(query: string): Promise<KnowledgeGraph>;
    openNodes(names: string[]): Promise<KnowledgeGraph>;
}
//# sourceMappingURL=knowledge-graph.d.ts.map