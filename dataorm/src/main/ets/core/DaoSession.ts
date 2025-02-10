/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
    *
  * http://www.apache.org/licenses/LICENSE-2.0
    *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

import { AbstractDaoSession } from './AbstractDaoSession';
import { Database } from './database/Database';
import { IdentityScopeType } from './identityscope/IdentityScopeType';
import { DaoConfig } from './internal/DaoConfig';
import { JMap } from './common/JMap';
import { BaseDao } from './BaseDao';
import { GlobalContext } from './GlobalContext';
import { DbUtils } from './DbUtils';

export class DaoSession extends AbstractDaoSession {
    private daoConfigObj = {};
    private daoObj = {};

    constructor(db: Database, type_s: IdentityScopeType,
                daoConfigMap: JMap<string
                , DaoConfig>) {
        super(db);
        const uniqueKeyForEntities = `${GlobalContext.KEY_CLS_ARRAY}_${db.name}${db.customDir ? '_'+db.customDir : ''}`;
        let entities = GlobalContext.getContext().getValue(uniqueKeyForEntities) as any[];
        if (entities) {
            for (let entity of entities) {
                let dbName = DbUtils.getEntityClassName(entity)
                this.daoConfigObj[dbName] = daoConfigMap.get(dbName);
                this.daoConfigObj[dbName].initIdentityScope(type_s);

                let daoSessions: DaoSession = this
                if (this.daoObj == undefined) {
                    this.daoObj = {};
                }
                this.daoObj[dbName+'Dao'] = new BaseDao<typeof entity, number>(this.daoConfigObj[dbName], daoSessions);
                this.daoObj[dbName+'Dao'].setEntityCls(entity);
                this.registerDao(dbName, this.daoObj[dbName+'Dao']);
            }
        }
    }

    public clear() {
        if (this.daoConfigObj) {
            for (let daoConfigName in this.daoConfigObj) {
                this.daoConfigObj[daoConfigName].clearIdentityScope();
            }
        }
    }

    public getBaseDao<T, K>(entity: any): BaseDao<T, K> {
        if (this.daoObj != undefined) {
            let dbName = DbUtils.getEntityClassName(entity)
            return this.daoObj[dbName+'Dao'];
        } else {
            return undefined;
        }
    }
}
