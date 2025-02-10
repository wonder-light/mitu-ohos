/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Based on SQLiteOpenHelper.java written by
  * Copyright (C) 2011-2016 Markus Junginger, greenrobot (http://greenrobot.org)
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *   http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

import dataRdb from '@ohos.data.relationalStore';
import { GlobalContext } from '../GlobalContext';

import { StorageUtils } from '../StorageUtils'
import { Unit8ArrayUtils } from '../Unit8ArrayUtils'

export abstract class SQLiteOpenHelper {
  context: any;
  dbPath: string;
  dbName: string;
  mNewVersion: number = 1;
  cfg = undefined;
  encrypt: boolean = false;
  customDir: string;

  public constructor(context: any, name: string, version: number, customDir?: string, factory?: any, errorHandler?: any) {
    this.dbName = name;
    this.context = context;
    this.mNewVersion = version;
    this.customDir = customDir;
  }

  getDatabaseName(): string {
    return this.dbName;
  }

  async getWritableDatabase(): Promise<dataRdb.RdbStore> {
    this.onConfigure();
    let rdbStore = await this.getRdbStoreV9();
    let version = rdbStore.version;
    await this.onCreate(rdbStore, this.dbName, this.customDir);
    if (version != this.mNewVersion) {
      rdbStore.beginTransaction();
      if (version < this.mNewVersion) {
        await this.onUpgrade(rdbStore, version, this.mNewVersion);
      } else {
        await this.onDowngrade(rdbStore, version, this.mNewVersion);
      }
      rdbStore.version = this.mNewVersion;
      rdbStore.commit();
    }
    return rdbStore;
  }

  async getReadableDatabase(): Promise<dataRdb.RdbStore> {
    let rdbStore = await this.getRdbStoreV9();
    return rdbStore;
  }

  abstract onCreate(db: dataRdb.RdbStore, dbName:string, customDir: string);

  abstract onConfigure();

  abstract onUpgrade(db: dataRdb.RdbStore, oldVersion: number, newVersion: number);

  abstract onDowngrade(db: dataRdb.RdbStore, oldVersion: number, newVersion: number);

  onOpen(db: dataRdb.RdbStore) {
  }

  setEncrypt(encrypt: boolean) {
    this.encrypt = encrypt;
  }

  protected async getRdbStoreV9(): Promise<dataRdb.RdbStore> {
    this.mNewVersion = await StorageUtils.getValueByKey(this.dbName + "_dbVersion", 1, this.context);
    if (this.cfg == undefined) {
      this.cfg = {
        name: this.dbName,
        encrypt: this.encrypt,
        securityLevel: dataRdb.SecurityLevel.S1
      }
    }
    if(this.customDir) {
      this.cfg.customDir = this.customDir;
    }
    let promise = await dataRdb.getRdbStore(this.context, this.cfg);
    return promise;
  }

  protected getFileDir(): string {
    return this.context.filesDir;
  }
}
