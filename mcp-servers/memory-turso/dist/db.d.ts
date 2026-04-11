import { Client } from "@libsql/client";
export interface DbConfig {
    url: string;
    authToken?: string;
    localReplicaPath?: string;
}
export declare function getDbConfig(): DbConfig;
export declare function initializeDb(): Promise<Client>;
export declare function getDb(): Client;
export declare function syncReplica(): Promise<void>;
export declare function closeDb(): Promise<void>;
//# sourceMappingURL=db.d.ts.map