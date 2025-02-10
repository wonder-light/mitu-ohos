/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Based on AbstractDaoMaster.java written by
 * Copyright (C) 2011-2016 Markus Junginger, greenrobot (http://greenrobot.org)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Database } from './database/Database';
import { IdentityScopeType } from './identityscope/IdentityScopeType';
import { DaoConfig } from './internal/DaoConfig';
import { JMap as Map } from './common/JMap';
import { AbstractDaoSession } from './AbstractDaoSession';
import { DbUtils } from './DbUtils';

/**
 * The master of dao will guide you: start dao sessions with the master.
 *
 * @author Markus
 */
export abstract class AbstractDaoMaster {
    protected db: Database;
    protected schemaVersion: number;
    protected daoConfigMap: Map<string, DaoConfig>;
    public static daoUnit = {};

    constructor(db: Database, schemaVersion?: number) {
        this.db = db;
        if (schemaVersion) {
            this.schemaVersion = schemaVersion;
        }
        this.daoConfigMap = new Map<string, DaoConfig>();
    }

    protected registerDaoClass(entityCls: any): void {
        let dbName:string = DbUtils.getEntityClassName(entityCls);
        let daoConfig: DaoConfig = new DaoConfig(this.db, entityCls);
        this.daoConfigMap.put(dbName, daoConfig);
    }

    public getSchemaVersion(): number {
        return this.schemaVersion;
    }

    /** Gets the SQLiteDatabase for custom database access. Not needed for dataORM entities. */
    public getDatabase(): Database {
        return this.db;
    }

    public abstract newSession(): AbstractDaoSession;

    public abstract newSession(type: IdentityScopeType): AbstractDaoSession;
}

