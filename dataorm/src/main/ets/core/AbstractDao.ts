/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Based on AbstractDao.java written by
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

import dataRdb from '@ohos.data.relationalStore'
import { Database } from './database/Database';
import { DatabaseStatement } from './database/DatabaseStatement';
import { IdentityScope } from './identityscope/IdentityScope';
import { IdentityScopeLong } from './identityscope/IdentityScopeLong';
import { DaoConfig } from './internal/DaoConfig';
import { TableStatements } from './internal/TableStatements';
import { Query } from './query/Query';
import { QueryBuilder } from './query/QueryBuilder';
import { AbstractDaoSession } from './AbstractDaoSession';
import { Constraint, Property } from './Property';
import { SQLiteStatement } from './database/SQLiteStatement';
import { DaoException } from './DaoException';
import 'reflect-metadata';
import { JList } from './common/JList';
import { DaoLog } from './DaoLog';
import { ResultData } from './dbflow/base/ResultData';
import { Select } from './dbflow/base/Select';
import { ResultSetCallBack } from './dbflow/base/ResultSetCallBack'
import { OnTableChangedListener } from './dbflow/listener/OnTableChangedListener'
import { TableAction } from './dbflow/listener/TableAction'
import { JoinPropertyEntity } from './annotation/ToMany';
import { ToOneEntity } from './entity/ToOneEntity';
import { Entity } from './entity/Entity';
import { ToManyEntity } from './entity/ToManyEntity';
import { ToManyWithJoinEntity } from './entity/ToManyWithJoinEntity';
import relationalStore from '@ohos.data.relationalStore';
import { GlobalContext } from './GlobalContext';
import { ConvertParameter } from './converter/ConvertParameter';
import { Queue } from './common/Queue';
import { DbUtils } from './DbUtils';

/**
 * Base class for all DAOs: Implements entity operations like insert, load, delete, and query.
 * <p>
 * This class is thread-safe.
 *
 * @param <T> Entity type
 * @param <K> Primary key (PK) type; use Void if entity does not have exactly one PK
 * @author Markus
 */
export abstract class AbstractDao<T, K> {
  protected config: DaoConfig;
  protected db: Database;
  protected isStandardSQLite: boolean;
  protected identityScope: IdentityScope<K, T>;
  protected identityScopeLong: IdentityScopeLong<1, T>;
  protected statements: TableStatements;
  protected session: AbstractDaoSession;
  protected pkOrdinal: number;
  protected entityCls: any;
  protected convertEntity;
  protected columnType;
  protected convertColumn;

  public static TABLENAME<T>(t: T): string {
    return Reflect.getMetadata('Table', t);
  }

  public static INDEXINFO<T>(t: T): Array<{
    name?: string,
    value: string,
    unique: boolean
  }> {
    return Reflect.getMetadata('Indexes', t);
  }

  public setEntityCls(entityCls: T) {
    this.entityCls = entityCls;
  }

  public getEntityCls(): any {
    return this.entityCls;
  }

  constructor(config: DaoConfig, daoSession = null) {
    this.config = config;
    this.session = daoSession;
    this.db = config.db;
    this.isStandardSQLite = true;
    this.identityScope = <IdentityScope<K, T>> config.getIdentityScope();
    if (this.identityScope instanceof IdentityScopeLong) {
      this.identityScopeLong = <IdentityScopeLong<1, T>> this.identityScope;
    } else {
      this.identityScopeLong = null;
    }
    this.statements = config.statements;
    this.pkOrdinal = config.pkProperty != null ? config.pkProperty.ordinal : -1;
  }

  public getSession(): AbstractDaoSession {
    return this.session;
  }

  getStatements(): TableStatements {
    return this.config.statements;
  }

  public getTableName(): string {
    return this.config.tablename;
  }

  public getProperties(): Property[] {
    return this.config.properties;
  }

  public getPkProperty(): Property {
    return this.config.pkProperty;
  }

  public getAllColumns(): string[] {
    return this.config.allColumns;
  }

  public getPkColumns(): string[] {
    return this.config.pkColumns;
  }

  public getNonPkColumns(): string[] {
    return this.config.nonPkColumns;
  }

  /**
   * Loads the entity for the given PK.
   *
   * @param key a PK value or null
   * @return The entity or null, if no entity matched the PK value
   */
  public async load(key: K): Promise<T> {
    if (key == null) {
      return null;
    }
    if (this.identityScope != null) {
      let entity: T = this.identityScope.get(key);
      if (entity != null && entity != undefined) {
        return new Promise<T>(resolve => {
          resolve(entity);
        })
      }
    }
    let sql = new dataRdb.RdbPredicates(this.getTableName())
    sql.equalTo(this.getPkColumns()[0], key.toString())
    // @ts-ignore
    let cursor: ResultSet = await this.db.rawQuery(sql, this.getAllColumns());
    if (cursor && cursor.goToFirstRow()) {
      return new Promise<T>(resolve => {
        let data = this.loadUniqueAndCloseCursor(cursor);
        if (data)
          resolve(data);
        else return undefined;
      })
    } else return undefined;
  }

  public async loadByRowId(rowId: number): Promise<T> {
    let sql = this.statements.getSelectAll();
    sql.equalTo("ROWID", rowId.toString());
    let cursor = await this.db.rawQuery(sql, this.getAllColumns());
    return this.loadUniqueAndCloseCursor(cursor);
  }

  protected loadUniqueAndCloseCursor(cursor: any): T {
    try {
      return this.loadUnique(cursor);
    } finally {
      if (cursor) {
        cursor.close();
      }
    }
  }

  protected loadUnique(cursor: any): T {
    if (cursor) {
      let available: boolean = cursor.goToFirstRow();
      if (!available) {
        return undefined;
      }
      return this.loadCurrent(cursor, 0, true);
    } else {
      return undefined;
    }
  }

  /** Loads all available entities from the database. */
  public async loadAll(): Promise<Array<T>> {
    // @ts-ignore
    let cursor: ResultSet = await this.db.rawQuery(this.statements.getSelectAll(), this.getAllColumns());
    return this.loadAllAndCloseCursor(cursor);
  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#loadAllsAsync
   */
  public loadAlls() {
    // @ts-ignore
    let cursor: ResultSet = this.db.rawQueries(this.getSelectDeep(entity), this.getAllColumns());
    return this.loadAllAndCloseCursor(cursor);
  }

  public async loadAllsAsync() {
    // @ts-ignore
    let cursor: ResultSet = await this.db.rawQueries(this.getSelectDeep(entity), this.getAllColumns());
    return this.loadAllAndCloseCursor(cursor);

  }

  /** Detaches an entity from the identity scope (session). Subsequent query results won't return this object. */
  public detach(entity: T): boolean {
    if (this.identityScope != null) {
      let key: K = this.getKeyVerified(entity);
      return this.identityScope.detach(key, entity);
    } else {
      return false;
    }
  }

  /**
   * Detaches all entities (of type T) from the identity scope (session). Subsequent query results won't return any
   * previously loaded objects.
   */
  public detachAll(): void {
    if (this.identityScope != null) {
      this.identityScope.clear();
    }
  }

  protected loadAllAndCloseCursor<Y extends any = T>(cursor: any, isAs?: boolean): Array<Y> {
    try {
      return this.loadAllFromCursor<Y>(cursor, isAs);
    } finally {
      if (cursor) {
        cursor.close();
      }
    }
  }

  /**
   * Inserts the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertInTxIterableAsync
   */
  public insertInTxIterable(entities: Iterable<T>): void {
    this.insertInTx(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   */
  public async insertInTxIterableAsync(entities: Iterable<T>): Promise<void> {
    await this.insertInTxAsync(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertInTxArrAsync
   */
  public insertInTxArr(...entities: any[]): void {
    this.insertInTx(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   */
  public async insertInTxArrAsync(...entities: any[]): Promise<void> {
    await this.insertInTxAsync(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts the given entities in the database using a transaction. The given entities will become tracked if the PK
   * is set.
   *
   * @param entities      The entities to insert.
   * @param setPrimaryKey if true, the PKs of the given will be set after the insert; pass false to improve
   *                      performance.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertInTxAsync
   */
  public insertInTx(entities: Iterable<T>, setPrimaryKey: boolean): void {
    let stmt: DatabaseStatement = this.statements.getInsertStatement();
    this.executeInsertInTx(stmt, entities, setPrimaryKey);
  }

  /**
   * Inserts the given entities in the database using a transaction. The given entities will become tracked if the PK
   * is set.
   *
   * @param entities      The entities to insert.
   * @param setPrimaryKey if true, the PKs of the given will be set after the insert; pass false to improve
   *                      performance.
   */
  public async insertInTxAsync(entities: Iterable<T>, setPrimaryKey: boolean): Promise<void> {
    let stmt: DatabaseStatement = this.statements.getInsertStatement();
    await this.executeInsertInTx(stmt, entities, setPrimaryKey);
  }

  /**
   * Inserts or replaces the given entities in the database using a transaction. The given entities will become
   * tracked if the PK is set.
   *
   * @param entities      The entities to insert.
   * @param setPrimaryKey if true, the PKs of the given will be set after the insert; pass false to improve
   *                      performance.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertOrReplaceInTxAsync
   */
  public insertOrReplaceInTx(entities: Iterable<T>, setPrimaryKey: boolean): void {
    let stmt: DatabaseStatement = this.statements.getInsertOrReplaceStatement();
    this.executeInsertInTx(stmt, entities, setPrimaryKey);
  }

  /**
   * Inserts or replaces the given entities in the database using a transaction. The given entities will become
   * tracked if the PK is set.
   *
   * @param entities      The entities to insert.
   * @param setPrimaryKey if true, the PKs of the given will be set after the insert; pass false to improve
   *                      performance.
   */
  public async insertOrReplaceInTxAsync(entities: Iterable<T>, setPrimaryKey: boolean): Promise<void> {
    let stmt: DatabaseStatement = this.statements.getInsertOrReplaceStatement();
    await this.executeInsertInTx(stmt, entities, setPrimaryKey);
  }

  // todo 对应原insertOrReplaceInTx
  /**
   * Inserts or replaces the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertOrReplaceInTxIterableAsync
   */
  public insertOrReplaceInTxIterable(entities: Iterable<T>): void {
    this.insertOrReplaceInTx(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts or replaces the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   */
  public async insertOrReplaceInTxIterableAsync(entities: Iterable<T>): Promise<void> {
    await this.insertOrReplaceInTxAsync(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts or replaces the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#insertOrReplaceInTxArrAsync
   */
  public insertOrReplaceInTxArr(...entities: any[]): void {
    this.insertOrReplaceInTx(entities, this.isEntityUpdateAble());
  }

  /**
   * Inserts or replaces the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   */
  public async insertOrReplaceInTxArrAsync(...entities: any[]): Promise<void> {
    let entity = entities.flat(Infinity);
    await this.insertOrReplaceInTxAsync(entity, this.isEntityUpdateAble());
  }

  private async executeInsertInTx(stmt: DatabaseStatement, entities: Iterable<T>, setPrimaryKey: boolean) {

    let err;
    try {
      this.db.beginTransaction();
      {
        if (this.identityScope != null) {
          this.identityScope.lock();
        }
        try {
          if (this.isStandardSQLite) {
            let rawStmt: SQLiteStatement = stmt.getRawStatement();
            for (let entity of entities) {
              this.bindValues(rawStmt, entity)
              if (setPrimaryKey) {
                let rowId: number = await rawStmt.executeInsert(relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
                this.updateKeyAfterInsertAndAttach(entity, rowId, false);
              } else {
                await rawStmt.executeInsert();
              }
            }
          } else {
            for (let entity of entities) {
              this.bindValues(stmt, entity)
              if (setPrimaryKey) {
                let rowId: number = await stmt.executeInsert();
                this.updateKeyAfterInsertAndAttach(entity, rowId, false);
              } else {
                await stmt.executeInsert();
              }
            }
          }
        } finally {
          if (this.identityScope != null) {
            this.identityScope.unlock();
          }
        }
      }
      this.db.endTransaction();
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }

    if (err) {
      throw err;
    }
  }

  /**
   * Insert an entity into the table associated with a concrete DAO.
   *
   * @return row ID of newly inserted entity
   */
  public async insert(entity: T): Promise<number> {
    return await this.executeInsert(entity, this.statements.getInsertStatement(), true);
  }

  /**
   * Insert an entity into the table associated with a concrete DAO <b>without</b> setting key property.
   * <p>
   * Warning: This may be faster, but the entity should not be used anymore. The entity also won't be attached to
   * identity scope.
   *
   * @return row ID of newly inserted entity
   */
  public async insertWithoutSettingPk(entity: T): Promise<number> {
    return await this.executeInsert(entity, this.statements.getInsertOrReplaceStatement(), false);
  }

  /**
   * Insert an entity into the table associated with a concrete DAO.
   *
   * @return row ID of newly inserted entity
   */
  public async insertOrReplace(entity: T, setKeyAndAttach: boolean = true): Promise<number> {
    return await this.executeInsert(entity, this.statements.getInsertOrReplaceStatement(), setKeyAndAttach, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);
  }

  private async executeInsert(entity: T, stmt: DatabaseStatement, setKeyAndAttach: boolean, conflictResolution?: relationalStore.ConflictResolution): Promise<number> {
    let rowId: number;
    let err;
    this.db.beginTransaction();
    try {
      rowId = await this.insertInsideTx(entity, stmt, conflictResolution);
      this.db.endTransaction();
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }

    if (setKeyAndAttach) {
      this.updateKeyAfterInsertAndAttach(entity, rowId, true);
    }
    return rowId;
  }

  private async insertInsideTx(entity: T, stmt: DatabaseStatement, conflictResolution?: relationalStore.ConflictResolution): Promise<number> {
    {
      if (this.isStandardSQLite) {
        let rawStmt: SQLiteStatement = stmt.getRawStatement();
        this.bindValues(rawStmt, entity);
        return await rawStmt.executeInsert(conflictResolution);
      } else {
        this.bindValues(stmt, entity);
        return await stmt.executeInsert(conflictResolution);
      }
    }
  }


  protected updateKeyAfterInsertAndAttach(entity: T, rowId: number, lock: boolean): void {
    if (rowId != -1) {
      let key: K = this.updateKeyAfterInsert(entity, rowId);
      this.attachEntityM(key, entity, lock);
    } else {
      // TODO When does this actually happen? Should we throw instead?
      DaoLog.w("Could not insert row (executeInsert returned -1)");
    }
  }

  /**
   * "Saves" an entity to the database: depending on the existence of the key property, it will be inserted
   * (key is null) or updated (key is not null).
   * <p>
   * This is similar to {@link #insertOrReplace(Object)}, but may be more efficient, because if a key is present,
   * it does not have to query if that key already exists.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#saveAsync
   */
  public save(entity: T): void {
    if (this.hasKey(entity)) {
      this.update(entity);
    } else {
      this.insert(entity);
    }
  }

  /**
   * "Saves" an entity to the database: depending on the existence of the key property, it will be inserted
   * (key is null) or updated (key is not null).
   * <p>
   * This is similar to {@link #insertOrReplace(Object)}, but may be more efficient, because if a key is present,
   * it does not have to query if that key already exists.
   */
  public async saveAsync(entity: T): Promise<void> {
    if (this.hasKey(entity)) {
      await this.updateAsync(entity);
    } else {
      await this.insert(entity);
    }
  }

  /**
   * Saves (see {@link #save(Object)}) the given entities in the database using a transaction.
   *
   * @param entities The entities to save.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#saveInTxAAsync
   */
  public saveInTxA(...entities: any[]): void {
    this.saveInTx(entities);
  }

  /**
   * Saves (see {@link #save(Object)}) the given entities in the database using a transaction.
   *
   * @param entities The entities to save.
   */
  public async saveInTxAAsync(...entities: any[]): Promise<void> {
    await this.saveInTxAsync(entities);
  }

  /**
   * Saves (see {@link #save(Object)}) the given entities in the database using a transaction.
   *
   * @param entities The entities to save.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#saveInTxAsync
   */
  public saveInTx(entities: Iterable<T>): void {
    let updateCount: number = 0;
    let insertCount: number = 0;
    for (let entity of entities) {
      if (this.hasKey(entity)) {
        updateCount++;
      } else {
        insertCount++;
      }
    }
    if (updateCount > 0 && insertCount > 0) {
      let toUpdate: JList<T> = new JList();
      let toInsert: JList<T> = new JList();
      for (let entity of entities) {
        if (this.hasKey(entity)) {
          toUpdate.insert(entity);
        } else {
          toInsert.insert(entity);
        }
      }

      let err;
      this.db.beginTransaction();
      try {
        this.updateInTx(toUpdate.dataSource);
        this.insertInTxIterable(toInsert.dataSource);
        this.db.endTransaction();
      } catch (e) {
        console.error("err_msg:" + e.message + "--err:" + e.stack)
        this.db.rollBack()
        err = e;
      }
      if (err) {
        throw err;
      }
    } else if (insertCount > 0) {
      this.insertInTxIterable(entities);
    } else if (updateCount > 0) {
      this.updateInTx(entities);
    }
  }

  /**
   * Saves (see {@link #save(Object)}) the given entities in the database using a transaction.
   *
   * @param entities The entities to save.
   */
  public async saveInTxAsync(entities: Iterable<T>): Promise<void> {
    let updateCount: number = 0;
    let insertCount: number = 0;
    for (let entity of entities) {
      if (this.hasKey(entity)) {
        updateCount++;
      } else {
        insertCount++;
      }
    }
    if (updateCount > 0 && insertCount > 0) {
      let toUpdate: JList<T> = new JList();
      let toInsert: JList<T> = new JList();
      for (let entity of entities) {
        if (this.hasKey(entity)) {
          toUpdate.insert(entity);
        } else {
          toInsert.insert(entity);
        }
      }

      let err;
      this.db.beginTransaction();
      try {
        await this.updateInTxAsync(toUpdate.dataSource);
        await this.insertInTxIterableAsync(toInsert.dataSource);
        this.db.endTransaction();
      } catch (e) {
        console.error("err_msg:" + e.message + "--err:" + e.stack)
        this.db.rollBack()
        err = e;
      }
      if (err) {
        throw err;
      }
    } else if (insertCount > 0) {
      await this.insertInTxIterableAsync(entities);
    } else if (updateCount > 0) {
      await this.updateInTxAsync(entities);
    }
  }

  public convertCursor2Entity(cursor: any): Array<T> {
    return this.loadAllFromCursor(cursor);
  }


  /** Reads all available rows from the given cursor and returns a JList of entities. */
  protected loadAllFromCursor<Y extends any = T>(cursor: dataRdb.ResultSet, isAs?: boolean): Array<Y> {

    let count: number = cursor.rowCount;
    if (count == 0) {
      return new JList<Y>().dataSource;
    }
    let list: JList<Y> = new JList<Y>();
    if (cursor && cursor.goToFirstRow()) {

      if (this.identityScope != null) {
        this.identityScope.lock();
        this.identityScope.reserveRoom(count);
      }

      try {
        do {
          let value = isAs === true ? this.loadCurrentAs<Y>(cursor, 0, false) : this.loadCurrent(cursor, 0, false);
          list.insert(value as Y);
        } while (cursor.goToNextRow());
      } finally {
        if (this.identityScope != null) {
          this.identityScope.unlock();
        }
      }
    }
    return list.dataSource;
  }

  /** Internal use only. Considers identity scope. */
  protected loadCurrent(cursor: dataRdb.ResultSet, offset: number, lock: boolean): T {
    if (this.identityScopeLong != null) {
      if (offset != 0) {
        // Occurs with deep loads (left outer joins)
        if (cursor.isColumnNull(this.pkOrdinal + offset)) {
          return null;
        }
      }
      let key: number = cursor.getLong(this.pkOrdinal + offset);
      let entity: T = lock ? this.identityScopeLong.get2(key) : this.identityScopeLong.get2NoLock(key);
      if (entity != null) {
        return entity;
      } else {
        entity = this.readEntity(cursor, offset);
        this.attachEntity(entity);
        if (lock) {
          this.identityScopeLong.put2(key, entity);
        } else {
          this.identityScopeLong.put2NoLock(key, entity);
        }
        return entity;
      }
    } else if (this.identityScope != null) {
      let entity: T = this.readEntity(cursor, offset);
      return entity;
    } else {
      // Check offset, assume a value !=0 indicating a potential outer join, so check PK
      if (offset != 0) {
        let key: K = this.readKey(cursor, offset);
        if (key == null) {
          // Occurs with deep loads (left outer joins)
          return null;
        }
      }

      let entity: T = this.readEntity(cursor, offset);
      this.attachEntity(entity);
      return entity;
    }
  }

  /**
   * 返回实体对象而不是对应的类
   */
  protected loadCurrentAs<Y extends any = T>(cursor: dataRdb.ResultSet, offset: number, lock: boolean): Y {
    return this.readEntityAs<Y>(cursor, offset);
  }

  /** Internal use only. Considers identity scope. */
  protected loadCurrentOther<O>(dao: AbstractDao<O, any>, cursor: any, offset: number): O {
    return dao.loadCurrent(cursor, offset, /* TODO check this */
      true);
  }

  /** A raw-style query where you can pass any WHERE clause and arguments. */
  public async queryRaw(where: string, ...selectionArg: string[]): Promise<Array<T>> {
    // @ts-ignore
    let cursor: ResultSet = await this.db.rawQuery(this.statements.getSelectAll() + where, selectionArg);
    return this.loadAllAndCloseCursor(cursor);
  }

  /**
   * Creates a repeatable {@link Query} object based on the given raw SQL where you can pass any WHERE clause and
   * arguments.
   */
  public queryRawCreate(where: string, ...selectionArg: any[]): Query<T> {
    return this.queryRawCreateListArgs(where, selectionArg);
  }


  /**
   * Creates a repeatable {@link Query} object based on the given raw SQL where you can pass any WHERE clause and
   * arguments.
   */
  public queryRawCreateListArgs(where: string, selectionArg: any[]): Query<T> {
    return Query.internalCreate(this, null, selectionArg);
  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteAllAsync
   */
  public deleteAll(): void {
    this.db.execSQL("DELETE FROM '" + this.config.tablename + "'");
    if (this.identityScope != null) {
      this.identityScope.clear();
    }
  }

  public async deleteAllAsync(): Promise<void> {
    await this.db.execSQL("DELETE FROM '" + this.config.tablename + "'");
    if (this.identityScope != null) {
      this.identityScope.clear();
    }
  }

  /**
   * Deletes the given entity from the database. Currently, only single value PK entities are supported.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteAsync
   * */
  public delete(entity: T): void {
    this.assertSinglePk();
    let key: K = this.getKeyVerified(entity);
    this.deleteByKey(key);
  }

  /**
   * Deletes the given entity from the database. Currently, only single value PK entities are supported.
   * */
  public async deleteAsync(entity: T): Promise<void> {
    this.assertSinglePk();
    let key: K = this.getKeyVerified(entity);
    await this.deleteByKeyAsync(key);
  }

  /**
   * Deletes an entity with the given PK from the database. Currently, only single value PK entities are supported.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteByKeyAsync
   * */
  public deleteByKey(key: K): void {

    let stmt: DatabaseStatement = this.statements.getDeleteStatement();
    let err;
    this.db.beginTransaction();
    try {
      this.deleteByKeyInsideSynchronized(key, stmt);
      this.db.endTransaction();
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }

    if (this.identityScope != null) {
      this.identityScope.remove(key);
    }
  }

  /**
   * Deletes an entity with the given PK from the database. Currently, only single value PK entities are supported.
   * */
  public async deleteByKeyAsync(key: K): Promise<void> {
    let stmt: DatabaseStatement = this.statements.getDeleteStatement();
    let err;
    this.db.beginTransaction();
    try {
      await this.deleteByKeyInsideAsync(key, stmt);
      this.db.endTransaction();
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }

    if (this.identityScope != null) {
      this.identityScope.remove(key);
    }
  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteByKeyInsideAsync
   */
  private deleteByKeyInsideSynchronized(key: any, stmt: DatabaseStatement): void {
    stmt.clearBindings();
    if (key.constructor.name == "Number") {
      stmt.bindLong(0, key);
    } else if (key == null) {
      throw new DaoException("Cannot delete entity, key is null");
    } else {
      stmt.bindString(0, key.toString());
    }
    stmt.bindLong(0, key)

    let predicates = new dataRdb.RdbPredicates(this.getTableName())
    if (stmt instanceof SQLiteStatement) {
      stmt.sql = predicates;
      stmt.sql.equalTo(this.getPkColumns()[0], key.toString());
    } else {
      stmt.getRawStatement().sql = predicates;
      stmt.getRawStatement().sql.equalTo(this.getPkColumns()[0], key.toString());
    }
    stmt.executeDelete();

  }

  private async deleteByKeyInsideAsync(key: any, stmt: DatabaseStatement): Promise<void> {
    stmt.clearBindings();
    if (key.constructor.name == "Number") {
      stmt.bindLong(0, key);
    } else if (key == null) {
      throw new DaoException("Cannot delete entity, key is null");
    } else {
      stmt.bindString(0, key.toString());
    }
    stmt.bindLong(0, key)

    let predicates = new dataRdb.RdbPredicates(this.getTableName())
    if (stmt instanceof SQLiteStatement) {
      stmt.sql = predicates;
      stmt.sql.equalTo(this.getPkColumns()[0], key.toString());
    } else {
      stmt.getRawStatement().sql = predicates;
      stmt.getRawStatement().sql.equalTo(this.getPkColumns()[0], key.toString());
    }
    await stmt.executeDelete();

  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteInTxInternalAsync
   */
  private deleteInTxInternal(entities: Iterable<T>, keys: Iterable<K>): void {
    this.assertSinglePk();
    let stmt: DatabaseStatement = this.statements.getDeleteStatement();
    let keysToRemoveFromIdentityScope: JList<K> = null;
    let err;
    this.db.beginTransaction();
    try {
      {
        if (this.identityScope != null) {
          this.identityScope.lock();
          keysToRemoveFromIdentityScope = new JList<K>();
        }
        try {
          if (entities != null) {
            for (let entity of entities) {
              let key: K = this.getKeyVerified(entity);
              this.deleteByKeyInsideSynchronized(key, stmt);
              if (keysToRemoveFromIdentityScope != null) {
                keysToRemoveFromIdentityScope.insert(key);
              }
            }
          }
          if (keys != null) {
            for (let key of keys) {
              this.deleteByKeyInsideSynchronized(key, stmt);
              if (keysToRemoveFromIdentityScope != null) {
                keysToRemoveFromIdentityScope.insert(key);
              }
            }
          }
          this.db.endTransaction();
        } finally {
          if (this.identityScope != null) {
            this.identityScope.unlock();
          }
        }
      }
      if (keysToRemoveFromIdentityScope != null && this.identityScope != null) {
        for (let i = 0;i < keysToRemoveFromIdentityScope.listSize; i++) {
          this.identityScope.remove(keysToRemoveFromIdentityScope[i]);
        }
      }

    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }
  }

  private async deleteInTxInternalAsync(entities: Iterable<T>, keys: Iterable<K>): Promise<void> {
    this.assertSinglePk();
    let stmt: DatabaseStatement = this.statements.getDeleteStatement();
    let keysToRemoveFromIdentityScope: JList<K> = null;
    let err;
    this.db.beginTransaction();
    try {
      {
        if (this.identityScope != null) {
          this.identityScope.lock();
          keysToRemoveFromIdentityScope = new JList<K>();
        }
        try {
          if (entities != null) {
            for (let entity of entities) {
              let key: K = this.getKeyVerified(entity);
              await this.deleteByKeyInsideAsync(key, stmt);
              if (keysToRemoveFromIdentityScope != null) {
                keysToRemoveFromIdentityScope.insert(key);
              }
            }
          }
          if (keys != null) {
            for (let key of keys) {
              await this.deleteByKeyInsideAsync(key, stmt);
              if (keysToRemoveFromIdentityScope != null) {
                keysToRemoveFromIdentityScope.insert(key);
              }
            }
          }
          this.db.endTransaction();
        } finally {
          if (this.identityScope != null) {
            this.identityScope.unlock();
          }
        }
      }
      if (keysToRemoveFromIdentityScope != null && this.identityScope != null) {
        for (let i = 0;i < keysToRemoveFromIdentityScope.listSize; i++) {
          this.identityScope.remove(keysToRemoveFromIdentityScope[i]);
        }
      }

    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }
  }

  /**
   * Deletes the given entities in the database using a transaction.
   *
   * @param entities The entities to delete.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteInTxIterableAsync
   */
  public deleteInTxIterable(entities: Iterable<T>): void {
    this.deleteInTxInternal(entities, null);
  }

  /**
   * Deletes the given entities in the database using a transaction.
   *
   * @param entities The entities to delete.
   */
  public async deleteInTxIterableAsync(entities: Iterable<T>): Promise<void> {
    await this.deleteInTxInternalAsync(entities, null);
  }

  /**
   * Deletes the given entities in the database using a transaction.
   *
   * @param entities The entities to delete.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteInTxArrAsync
   */
  public deleteInTxArr(...entities: any[]): void {
    this.deleteInTxInternal(entities, null);
  }

  /**
   * Deletes the given entities in the database using a transaction.
   *
   * @param entities The entities to delete.
   */
  public async deleteInTxArrAsync(...entities: any[]): Promise<void> {
    await this.deleteInTxInternalAsync(entities, null);
  }

  /**
   * Deletes all entities with the given keys in the database using a transaction.
   *
   * @param keys Keys of the entities to delete.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteByKeyInTxIterableAsync
   */
  public deleteByKeyInTxIterable(keys: Iterable<K>): void {
    this.deleteInTxInternal(null, keys);
  }

  /**
   * Deletes all entities with the given keys in the database using a transaction.
   *
   * @param keys Keys of the entities to delete.
   */
  public async deleteByKeyInTxIterableAsync(keys: Iterable<K>): Promise<void> {
    await this.deleteInTxInternalAsync(null, keys);
  }

  /**
   * Deletes all entities with the given keys in the database using a transaction.
   *
   * @param keys Keys of the entities to delete.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#deleteByKeyInTxArrAsync
   */
  public deleteByKeyInTxArr(...keys: K[]): void {
    this.deleteInTxInternal(null, keys);
  }

  /**
   * Deletes all entities with the given keys in the database using a transaction.
   *
   * @param keys Keys of the entities to delete.
   */
  public async deleteByKeyInTxArrAsync(...keys: K[]): Promise<void> {
    await this.deleteInTxInternalAsync(null, keys);
  }

  /** Resets all locally changed properties of the entity by reloading the values from the database. */
  public async refresh(entity: T): Promise<void> {
    this.assertSinglePk();
    let key: K = this.getKeyVerified(entity);
    let sql = this.statements.getSelectByKey();
    sql.equalTo(this.getPkColumns()[0], key.toString())

    let cursor: dataRdb.ResultSet = await this.db.rawQuery(sql, this.getAllColumns());
    try {
      if (cursor) {
        let available: boolean = cursor.goToFirstRow();
        if (!available) {
          throw new DaoException("Entity does not exist in the database anymore: " + entity
          + " with key " + key);
        } else if (cursor.rowCount === 0) {
          throw new DaoException("Expected unique result, but count was " + cursor.rowCount);
        }
        this.readEntity2(cursor, entity, 0);
        this.attachEntityM(key, entity, true);
      }
    } finally {
      if (cursor) {
        cursor.close();
      }
    }
  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#updateAsync
   */
  public update(entity: T, conflictResolution?: relationalStore.ConflictResolution): void {
    let stmt: DatabaseStatement = this.statements.getUpdateStatement();
    let err;
    this.db.beginTransaction();
    try {
      this.updateInsideSynchronized(entity, stmt, true, conflictResolution);
      this.db.endTransaction();
    } catch (e) {
      console.error("update err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }
  }

  public async updateAsync(entity: T, conflictResolution?: relationalStore.ConflictResolution): Promise<void> {
    let stmt: DatabaseStatement = this.statements.getUpdateStatement();
    let err;
    this.db.beginTransaction();
    try {
      await this.updateInsideAsync(entity, stmt, true, conflictResolution);
      this.db.endTransaction();
    } catch (e) {
      console.error("update err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      err = e;
    }
    if (err) {
      throw err;
    }
  }

  public queryBuilder(): QueryBuilder<T> {
    return QueryBuilder.internalCreate(this);
  }

  /**
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#updateInsideAsync
   */
  protected updateInsideSynchronized(entity: T, stmt: SQLiteStatement | DatabaseStatement, lock: boolean, conflictResolution?: relationalStore.ConflictResolution): void {
    // To do? Check if it's worth not to bind PKs here (performance).
    stmt.clearBindings();
    this.bindValues(stmt, entity);
    let key: K = this.getKey(entity);
    if (key.constructor.name == "Number") {
      let tmp: any = key;
      stmt.bindLong(1, <number> tmp);
    } else if (key == null) {
      throw new DaoException("Cannot update entity without key - was it inserted before?");
    } else {
      stmt.bindString(1, key.toString());
    }

    let predicates = new dataRdb.RdbPredicates(this.getTableName())
    if (stmt instanceof SQLiteStatement) {
      stmt.sql = predicates;
      stmt.sql.equalTo(this.getPkColumns()[0], key.toString());
    } else {
      stmt.getRawStatement().sql = predicates;
      stmt.getRawStatement().sql.equalTo(this.getPkColumns()[0], key.toString());
    }
    // 异步代码
    stmt.executeUpdate(conflictResolution);
    this.attachEntityM(key, entity, lock);
  }

  protected async updateInsideAsync(entity: T, stmt: SQLiteStatement | DatabaseStatement, lock: boolean, conflictResolution?: relationalStore.ConflictResolution): Promise<void> {
    // To do? Check if it's worth not to bind PKs here (performance).
    stmt.clearBindings();
    this.bindValues(stmt, entity);
    let key: K = this.getKey(entity);
    if (key.constructor.name == "Number") {
      let tmp: any = key;
      stmt.bindLong(1, <number> tmp);
    } else if (key == null) {
      throw new DaoException("Cannot update entity without key - was it inserted before?");
    } else {
      stmt.bindString(1, key.toString());
    }

    let predicates = new dataRdb.RdbPredicates(this.getTableName())
    if (stmt instanceof SQLiteStatement) {
      stmt.sql = predicates;
      stmt.sql.equalTo(this.getPkColumns()[0], key.toString());
    } else {
      stmt.getRawStatement().sql = predicates;
      stmt.getRawStatement().sql.equalTo(this.getPkColumns()[0], key.toString());
    }
    // 异步代码
    await stmt.executeUpdate(conflictResolution);
    this.attachEntityM(key, entity, lock);
  }


  /**
   * Attaches the entity to the identity scope. Calls attachEntity(T entity).
   *
   * @param key    Needed only for identity scope, pass null if there's none.
   * @param entity The entity to attach
   */
  protected attachEntityM(key: K, entity: T, lock: boolean): void {
    this.attachEntity(entity);
    if (this.identityScope != null && key != null) {
      if (lock) {
        this.identityScope.put(key, entity);
      } else {
        this.identityScope.putNoLock(key, entity);
      }
    }
  }

  /**
   * Sub classes with relations additionally set the DaoMaster here. Must be called before the entity is attached to
   * the identity scope.
   *
   * @param entity The entity to attach
   */
  protected attachEntity(entity: T): void {
  }

  /**
   * Updates the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#updateInTxIterableAsync
   */
  public updateInTxIterable(entities: Iterable<T>): void {
    let stmt: DatabaseStatement = this.statements.getUpdateStatement();
    this.db.beginTransaction();
    // txEx: just to preserve original exception in case another exceptions is thrown in endTransaction()
    let txEx: Error = null;
    try {
      if (this.identityScope != null) {
        this.identityScope.lock();
      }
      try {
        if (this.isStandardSQLite) {
          let rawStmt: SQLiteStatement = stmt.getRawStatement();
          for (let entity of entities) {
            this.updateInsideSynchronized(entity, rawStmt, false);
          }
        } else {
          for (let entity of entities) {
            this.updateInsideSynchronized(entity, stmt, false);
          }
        }
        this.db.endTransaction();
      } finally {
        if (this.identityScope != null) {
          this.identityScope.unlock();
        }
      }
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      txEx = e;
    }
    if (txEx != null) {
      throw txEx;
    }
  }

  /**
   * Updates the given entities in the database using a transaction.
   *
   * @param entities The entities to insert.
   */
  public async updateInTxIterableAsync(entities: Iterable<T>): Promise<void> {
    let stmt: DatabaseStatement = this.statements.getUpdateStatement();
    this.db.beginTransaction();
    // txEx: just to preserve original exception in case another exceptions is thrown in endTransaction()
    let txEx: Error = null;
    try {
      if (this.identityScope != null) {
        this.identityScope.lock();
      }
      try {
        if (this.isStandardSQLite) {
          let rawStmt: SQLiteStatement = stmt.getRawStatement();
          for (let entity of entities) {
            await this.updateInsideAsync(entity, rawStmt, false);
          }
        } else {
          for (let entity of entities) {
            await this.updateInsideAsync(entity, stmt, false);
          }
        }
        this.db.endTransaction();
      } finally {
        if (this.identityScope != null) {
          this.identityScope.unlock();
        }
      }
    } catch (e) {
      console.error("err_msg:" + e.message + "--err:" + e.stack)
      this.db.rollBack()
      txEx = e;
    }
    if (txEx != null) {
      throw txEx;
    }
  }

  /**
   * Updates the given entities in the database using a transaction.
   *
   * @param entities The entities to update.
   * @deprecated since 2.1.1
   * @useinstead AbstractDao#updateInTxAsync
   */
  public updateInTx(...entities: any[]): void {
    this.updateInTxIterable(entities);
  }

  /**
   * Updates the given entities in the database using a transaction.
   *
   * @param entities The entities to update.
   */
  public async updateInTxAsync(...entities: any[]): Promise<void> {
    entities = entities.flat(Infinity);
    await this.updateInTxIterableAsync(entities);
  }

  protected assertSinglePk(): void {
    if (this.config.pkColumns.length != 1) {
      throw new DaoException(this + " (" + this.config.tablename + ") does not have a single-column primary key");
    }
  }


  /** See {@link #getKey(Object)}, but guarantees that the returned key is never null (throws if null). */
  protected getKeyVerified(entity: T): K {
    let key: K = this.getKey(entity);
    if (key == null) {
      if (entity == null) {
        throw new Error("Entity may not be null");
      } else {
        throw new DaoException("Entity has no key");
      }
    } else {
      return key;
    }
  }

  /** Gets the SQLiteDatabase for custom database access. Not needed for dataORM entities. */
  public getDatabase(): Database {
    return this.db;
  }

  /** Reads the values from the current position of the given cursor and returns a new entity. */
  protected abstract readEntity(cursor: any, offset: number): T;

  protected abstract readEntityAs<Y extends any = T>(cursor: any, offset: number): Y;

  /** Reads the key from the current position of the given cursor, or returns null if there's no single-value key. */
  protected abstract readKey(cursor: any, offset: number): K;

  /** Reads the values from the current position of the given cursor into an existing entity. */
  protected abstract readEntity2(cursor: any, entity: T, offset: number): void;

  /**
   * Binds the entity's values to the statement. Make sure to synchronize the enclosing DatabaseStatement outside
   * of the method.
   */
  protected abstract bindValues(stmt: SQLiteStatement | DatabaseStatement, entity: T): void;

  /**
   * Updates the entity's key if possible (only for Long PKs currently). This method must always return the entity's
   * key regardless of whether the key existed before or not.
   */
  protected abstract updateKeyAfterInsert(entity: T, rowId: number): K;

  /**
   * Returns the value of the primary key, if the entity has a single primary key, or, if not, null. Returns null if
   * entity is null.
   */
  protected abstract getKey(entity: T): K;

  /**
   * Returns true if the entity is not null, and has a non-null key, which is also != 0.
   * entity is null.
   */
  protected abstract hasKey(entity: T): boolean;

  /** Returns true if the Entity class can be updated, e.g. for setting the PK after insert. */
  protected abstract isEntityUpdateAble(): boolean;

  public query(select: Select<any>): Promise<Array<T>> {
    let st = this.getDatabase();
    let key = this.getPkColumns()[0];
    let maps = select.getKeyMaps();
    let isHasKey = false;
    let valueId: number = -1;
    maps.forEach((v, k) => {
      if (k.toString() == key) {
        isHasKey = true;
        valueId = v
      }
    });
    if (isHasKey) {
      let array = new Array<any>();
      return this.load(<any> valueId).then(async (entry) => {
        if (entry)
          array.push(entry);
        if (st != null && st.getTableChangedListener()) {
          st.getTableChangedListener().onTableChanged(array, TableAction.QUERY)
        }
        return array;
      });
    } else {
      return this.buildSelect(select);
    }
  }

  public buildSelect(select: Select<any>): Promise<Array<T>> {
    let rdbStore = this.getDatabase().getRawDatabase()
    let that = this;
    let st = this.getDatabase();
    return rdbStore.query(select.build(), this.getAllColumns()).then(async (data) => {
      // 查询结果加入缓存
      let arraysT = that.loadAllFromCursor(data);
      if (st != null && st.getTableChangedListener()) {
        st.getTableChangedListener().onTableChanged(arraysT, TableAction.QUERY)
      }
      return arraysT;
    })

  }

  public async rawQuery(sql: string, selectionArgs?: Array<any>): Promise<any> {
    return await this.db.rawQueries(sql, selectionArgs)
  }

  private myOnTableChangedListener = null;

  /**
   * 添加监听
   * @param listener
   */
  public addTableChangedListener(listener: OnTableChangedListener<any>) {
    this.myOnTableChangedListener = listener;
    this.getDatabase().addTableChangedListener(listener)

  }

  /**
   *  取消监听
   */
  public removeTableChangedListener() {
    this.getDatabase().removeTableChangedListener();
    this.myOnTableChangedListener = null;
  }

  getTableChangedListener(): OnTableChangedListener<any> {
    return this.myOnTableChangedListener
  }

  public static getColumns(entity: any): string[] {
    return Object.keys(entity);
  }

  public static generatorProperties<T>(t: T): Property[] {
    let arr = this.generatorPropertyArr(t);
    return arr;
  }

  private static getType(types): string {
    let typestr;
    switch (types) {
      case 'string':
      case 'String':
        typestr = 'TEXT';
        break;
      case 'number':
      case 'Number':
        typestr = 'INTEGER';
        break;
      case 'real':
      case 'Real':
        typestr = 'REAL';
        break;
      case 'blob':
      case 'Blob':
        typestr = 'BLOB';
        break;
      default:
        typestr = 'TEXT';
    }
    return typestr
  }

  private static entity: Entity
  private static toOneRelations: Array<ToOneEntity> = [] // 存取一对一关系
  private static toManyRelations: Array<ToManyEntity> = [] // 存取一对多关系
  private static toManyWithJoinEntity: Array<any> = [] // 临时存放joinEntity的注解值

  /**
   * 循环开始之前
   *
   * @param entityCls
   */
  private static onStart(entityCls: any) {
    this.entity = new Entity()
    this.toOneRelations = []
    this.toManyRelations = []
    this.toManyWithJoinEntity = []

    this.entity.className = DbUtils.getEntityClassName(entityCls);
    this.entity.dbName = AbstractDao.TABLENAME(entityCls)
  }

  /**
   * 循环中
   *
   * @param index
   * @param item
   * @param entityCls
   */
  private static onResume(item: string, entityCls: any) {
    let toOneItem = this.getToOneItem(item, entityCls)
    let toManyItem = this.getToManyItem(item, entityCls)
    let joinEntityTempItem = this.getJoinEntityTempListItem(item, entityCls)

    if (toOneItem !== null) {
      this.toOneRelations.push(toOneItem)
    }
    if (toManyItem !== null) {
      this.toManyRelations.push(toManyItem)
    }
    if (joinEntityTempItem !== null) {
      this.toManyWithJoinEntity.push(joinEntityTempItem)
    }
  }

  /**
   * 循环结束
   */
  private static onEnd() {
    this.entity.toOneRelations = this.toOneRelations
    this.entity.toManyRelations = this.toManyRelations
    this.entity.joinEntityTempList = this.toManyWithJoinEntity
    GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[this.entity.className] = this.entity
  }

  /**
   * 所有的表都已初始化完毕
   */
  public static allTableIsCreateEnd() {
    let entityArr = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY);
    for (let entityClsRelationshipArrKey in entityArr) {

      // 处理ToOne
      let toOneRelations = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey]['toOneRelations']
      if (toOneRelations !== undefined && toOneRelations.length > 0) {
        toOneRelations.forEach(item => {
          let tempList = item.tempList || []
          let tempItem = tempList[0]
          if (tempItem) {
            let fkp = this.getFkProperties(entityClsRelationshipArrKey, tempItem)
            item.fkProperties = [fkp]
          }
        })
      }

      // 处理ToMany
      let toManyRelations = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey]['toManyRelations']
      if (toManyRelations !== undefined && toManyRelations.length > 0) {
        toManyRelations.forEach(item => {
          let tempList: Array<string> = item.tempList || []
          let sourceProperties: Property[] = []
          let targetProperties: Property[] = []
          tempList.forEach(tempListItem => {
            let where = tempListItem.split(',')[0]
            let colName = tempListItem.split(',')[1]
            let clsName = tempListItem.split(',')[2]

            switch (where) {
              case 'source':
                sourceProperties.push(this.getFkProperties(clsName, colName))
                break
              case 'target':
                targetProperties.push(this.getFkProperties(clsName, colName))
                break
            }
          })
          item.sourceProperties = sourceProperties
          item.targetProperties = targetProperties
          let targetClsName = item.targetEntityClsName
          let incomingToManyRelations = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations
          if (incomingToManyRelations !== undefined && incomingToManyRelations.length > 0) {
            GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations = incomingToManyRelations.concat([item])
          } else {
            GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations = [item]
          }
        })
      }

      // 处理 joinEntity
      let joinEntityTempList = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey]['joinEntityTempList']
      if (joinEntityTempList !== undefined && joinEntityTempList.length > 0) {
        var joinEntity = []
        joinEntityTempList.forEach(item => {
          let toManyWithJoinEntity: ToManyWithJoinEntity = new ToManyWithJoinEntity()
          // 取注解的值
          let entityName = item.entityName
          let sourcePropertyName = item.sourceProperty
          let targetPropertyName = item.targetProperty
          let itemName = item.item
          let clsName = item.clsName
          let targetClsName = item.targetClsName

          // 封装joinEntity的值
          let clsProperty = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityName]
          let entity = new Entity()
          entity.className = clsProperty.className
          entity.dbName = clsProperty.dbName
          entity.pkProperty = clsProperty.pkProperty

          // 封装父类的值
          toManyWithJoinEntity.joinEntity = entity
          toManyWithJoinEntity.name = itemName
          toManyWithJoinEntity.sourceEntityClsName = clsName
          toManyWithJoinEntity.targetEntityClsName = entityName
          toManyWithJoinEntity.sourceProperties = [this.getFkProperties(entityName, sourcePropertyName)]
          toManyWithJoinEntity.targetProperties = [this.getFkProperties(entityName, targetPropertyName)]

          joinEntity.push(toManyWithJoinEntity)

          // 给目标cls赋值incomingToManyRelations
          let incomingToManyRelations = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations
          if (incomingToManyRelations !== undefined && incomingToManyRelations.length > 0) {
            GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations = incomingToManyRelations.concat([toManyWithJoinEntity])
          } else {
            GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[targetClsName].incomingToManyRelations = [toManyWithJoinEntity]
          }

        })

        // 将原本的toMany的数组与joinEntity的数组进行合并
        let toManyRelations = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey].toManyRelations
        if (toManyRelations !== undefined && toManyRelations.length > 0) {
          GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey].toManyRelations = toManyRelations.concat(joinEntity)
        } else {
          GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey].toManyRelations = joinEntity
        }

      }
      let entity = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)[entityClsRelationshipArrKey]
      GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP)[entityClsRelationshipArrKey] = entity;
    }

    let res = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS_RE_SHIP_ARRAY)
  }

  /**
   * 根据传入的类名和变量名寻找属性对象
   *
   * @param className
   * @param itemName
   */
  private static getFkProperties(className, itemName): Property {
    let obj = GlobalContext.getContext().getValue(GlobalContext.KEY_CLS)[className]
    if (obj) {
      for (let objKey in obj) {
        if (obj[objKey].columnName == itemName) {
          return obj[objKey]
        }
      }
    }
    return null
  }

  /**
   * 获取toOne的item
   *
   * @param item
   * @param entityCls
   */
  private static getToOneItem(item: string, entityCls: any): ToOneEntity {
    let toOne = Reflect.getMetadata('ToOne', entityCls.prototype, item);
    if (toOne) {
      let toOneEntity = new ToOneEntity()
      toOneEntity.name = item
      toOneEntity.sourceEntityClsName = DbUtils.getEntityClassName(entityCls)
      toOneEntity.targetEntityClsName = DbUtils.getEntityClassName(toOne.targetObj)
      toOneEntity.tempList[0] = toOne.joinProperty
      return toOneEntity
    }
    return null
  }


  /**
   * 获取joinEntity的注解值
   *
   * @param className
   * @param itemName
   */
  private static getJoinEntityTempListItem(item: string, entityCls: any): any {
    let joinEntity: any = Reflect.getMetadata('JoinEntity', entityCls.prototype, item);
    if (joinEntity) {
      let res = {
        entityName: joinEntity.entityName,
        sourceProperty: joinEntity.sourceProperty,
        targetProperty: joinEntity.targetProperty,
        item: item,
        clsName: entityCls.name,
        targetClsName: joinEntity.targetClsName
      }
      return res
    }
    return null
  }

  /**
   * 获取toMany的item
   *
   * @param item
   * @param entityCls
   */
  private static getToManyItem(item: string, entityCls: any): ToManyEntity {
    let toMany: any = Reflect.getMetadata('ToMany', entityCls.prototype, item);
    let orderBy: string = Reflect.getMetadata('OrderBy', entityCls.prototype, item);

    if (toMany) {
      let targetClsName: string = JSON.parse(toMany).targetClsName
      let joinProperty: Array<JoinPropertyEntity> = JSON.parse(toMany).joinProperty

      let toManyEntity: ToManyEntity = new ToManyEntity()
      toManyEntity.name = item
      toManyEntity.sourceEntityClsName = entityCls.name
      toManyEntity.targetEntityClsName = targetClsName
      toManyEntity.orderBy = orderBy || ''

      toManyEntity.tempList = []
      joinProperty.forEach(item => { // 临时存储待查询的表名和属性名
        toManyEntity.tempList.push('source,' + item.name + ',' + this.entity.className, 'target,' + item.referencedName + ',' + targetClsName)
      })

      return toManyEntity
    }
    return null
  }

  public static assembleProperty(index: number, entityCls: Function, item: string,
                                 prefix: string, sourcesPropertyArray: Queue<string>, result: Array<Object>) {
    // 处理实体中过滤的属性名
    let transient = Reflect.getMetadata('Transient', entityCls.prototype, item);
    if (transient) {
      return;
    }
    let param = Reflect.getMetadata('Embedded', entityCls.prototype, item);
    if (param) {
      if (sourcesPropertyArray && sourcesPropertyArray.size() > index) {
        while (!sourcesPropertyArray.empty()) {
          sourcesPropertyArray.removeFirst();
          if (sourcesPropertyArray.size() === index) {
            break;
          }
        }
      }
      // 执行下层
      let prefix = param.prefix;
      let targetClass = param.targetClass;
      let embedColumnNames = Object.keys(new targetClass());
      if (!sourcesPropertyArray) {
        sourcesPropertyArray = new Queue<string>();
      }
      sourcesPropertyArray.add(item);
      index++;
      embedColumnNames.forEach((value, i) => {
        if (sourcesPropertyArray && sourcesPropertyArray.size() > index) {
          while (!sourcesPropertyArray.empty()) {
            sourcesPropertyArray.removeFirst();
            if (sourcesPropertyArray.size() === index) {
              break;
            }
          }
        }
        this.assembleProperty(index, targetClass, value, prefix, sourcesPropertyArray, result);
      })
    } else {
      let columnName: string = Reflect.getMetadata('Column', entityCls.prototype, item);
      let isPrimaryKey = Reflect.getMetadata('isPrimaryKey', entityCls.prototype, item);
      let autoincrement = Reflect.getMetadata('autoincrement', entityCls.prototype, item);
      let isUnionPrimaryKey = Reflect.getMetadata('isUnionPrimaryKey', entityCls.prototype, item);

      if (isUnionPrimaryKey) {
        isPrimaryKey = isUnionPrimaryKey;
      }

      // Converter处理
      let convert = Reflect.getMetadata('Convert', entityCls.prototype, item);
      let convertParam: ConvertParameter;
      if (convert) {
        if (!columnName) {
          columnName = item;
        }
        convertParam = new ConvertParameter(convert.converter, convert.columnType);
      }

      if (columnName) {
        let types = Reflect.getMetadata('Type', entityCls.prototype, item);
        if (convertParam) {
          types = convertParam.getColumnType();
        }
        let typestr = this.getType(types);
        if (prefix) {
          columnName = prefix + columnName;
        }

        let pro = new Property(index, typestr, item, isPrimaryKey, columnName, autoincrement, sourcesPropertyArray);
        pro.setConvertParamObj(convertParam);

        let orderBy = Reflect.getMetadata('OrderBy', entityCls.prototype, item);
        let notNull = Reflect.getMetadata('NotNull', entityCls.prototype, item);
        let uniques = Reflect.getMetadata('Unique', entityCls.prototype, item);

        if (orderBy || notNull || uniques) {
          let constraint: Constraint = new Constraint();
          if (orderBy) {
            constraint.setOrderBy(orderBy);
          }
          if (notNull) {
            constraint.setNotNull(notNull);
          }
          if (uniques) {
            constraint.setUnique(uniques);
          }
          pro.setConstraint(constraint);
        }

        let index_unique = Reflect.getMetadata('index_unique', entityCls.prototype, item);
        let index_name = Reflect.getMetadata('index_name', entityCls.prototype, item);
        if (index_unique != undefined) {
          pro.setIndex({ unique: index_unique, name: index_name });
        }

        if (isPrimaryKey == true && !sourcesPropertyArray) {
          this.entity.pkProperty = pro // 记录主键
        }
        result[result.length] = pro;
      }
    }
  }


  public static generatorPropertyArr(entityCls: any): Property[] {
    let arr: Property[] = [];
    let entity = new entityCls();
    let columns = this.getColumns(entity);

    let index: number = 0;
    let properties: Properties = {};

    this.onStart(entityCls)

    let arrays = new Array<Property>();
    let isUnionPrimaryKey = false;
    columns.forEach((item, idx) => {
      this.onResume(item, entityCls)
      if (!isUnionPrimaryKey) {
        isUnionPrimaryKey = Reflect.getMetadata('isUnionPrimaryKey', entityCls.prototype, item);
      }
      this.assembleProperty(0, entityCls, item, null, null, arrays);
    });

    if (arrays.length > 0) {
      arrays.forEach((obj, i) => {
        obj.setOrdinal(index);
        arr[index] = obj;
        obj.setUnionPrimaryKey(isUnionPrimaryKey);
        if (obj.getSourcesPropertyArray().size() > 0) {
          properties[obj.columnName] = obj;
        } else {
          properties[obj.name] = obj;
        }
        index++;
      })
    }

    GlobalContext.getContext().getValue(GlobalContext.KEY_CLS)[DbUtils.getEntityClassName(entityCls)] = properties;

    this.onEnd()

    return arr;
  }

  public static getCreateTableSql<T>(ifNotExists: boolean, entityCls: T): string {
    const constraint = ifNotExists ? "IF NOT EXISTS " : "";

    //    示例 let createSql = "CREATE TABLE " + constraint + "NOTE (" + //
    //    "ID INTEGER PRIMARY KEY AUTOINCREMENT," + // 0: id
    //    "TEXT TEXT NOT NULL," + // 1: text
    //    "COMMENT TEXT," + // 2: comment
    //    "DATE INTEGER," + // 3: date
    //    "TYPE TEXT);";// 4: type

    let createSql = '';
    let arr = AbstractDao.generatorProperties(entityCls);
    let str = "CREATE TABLE " + constraint + AbstractDao.TABLENAME(entityCls) + " (";
    if (arr && arr.length > 0) {
      let num = arr.length;
      let i = 1;
      let notNullStr = ' NOT NULL ';
      let unionPrimaryKeyStr = '';
      for (let property of arr) {
        str += property.columnName + ' ' + property.type + ' ';
        if (property.primaryKey) {
          if (property.unionPrimaryKey) {
            unionPrimaryKeyStr += property.columnName + ' ,';
          } else {
            str += 'PRIMARY KEY ';
          }
          if (property.autoincrement) {
            str += 'AUTOINCREMENT '
          }
        }
        let constraints = property.constraint;
        if (constraints) {
          if (constraints.notNull) {
            str += notNullStr;
          }

          if (constraints.uniques) {
            str += ' UNIQUE ';
          }

          if (i < num) {
            str += ',';
          }

        } else {
          if (i < num) {
            str += ',';
          }
        }
        i++;
      }
      if (unionPrimaryKeyStr) {
        str += ', PRIMARY KEY (' + unionPrimaryKeyStr.substring(0, unionPrimaryKeyStr.length -1) + ')'
      }
      str += ")";
    }
    createSql = str;
    return createSql;
  }

  private static createCompositeIndexSql<T>(ifNotExists: boolean, entityCls: T): string[] {
    const constraint = ifNotExists ? "IF NOT EXISTS " : " ";
    let propertiesArr = AbstractDao.generatorProperties(entityCls);
    let resultCompositeArr = [];
    let compositeIndexSql = '';
    let indexInfoArray = AbstractDao.INDEXINFO(entityCls);
    if (indexInfoArray && indexInfoArray.length > 0) {
      for (let i = 0;i < indexInfoArray.length; i++) {
        compositeIndexSql = 'CREATE ';
        let composite_index_unique = AbstractDao.INDEXINFO(entityCls)[i].unique;
        if (composite_index_unique) {
          compositeIndexSql += 'UNIQUE ';
        }
        compositeIndexSql += 'INDEX ' + constraint;
        var indexNameArr: Array<{
          value: string,
          order: string
        }> = AbstractDao.INDEXINFO(entityCls)[i].value.split(",").map((part) => {
          part = part.trim();
          if (/ ASC$/.test(part)) {
            return { value: part.slice(0, part.length - 4), order: '_ASC' };
          } else if (/ DESC$/.test(part)) {
            return { value: part.slice(0, part.length - 5), order: '_DESC' };
          } else {
            return { value: part, order: '_ASC' };
          }
        });

        if (AbstractDao.INDEXINFO(entityCls)[0].name) {
          compositeIndexSql += ' ' + AbstractDao.INDEXINFO(entityCls)[i].name;
        } else {
          if (AbstractDao.INDEXINFO(entityCls)[0].value) {
            compositeIndexSql += 'IDX_' + AbstractDao.TABLENAME(entityCls) + "_";
            for (let item of indexNameArr) {
              let property = propertiesArr.find((propertyItem) => {
                return propertyItem.name == item.value
              })
              if (property) {
                compositeIndexSql += property.columnName + item.order + '_';
              } else {
                console.error("Invalid SQL Statements form!");
                throw new Error("Invalid Statements!");
              }
            }
            compositeIndexSql = compositeIndexSql.substring(0, compositeIndexSql.length - 1);
          } else {
            console.error("Invalid SQL Statements form!");
            throw new Error("Invalid SQL Statements form!");
          }
        }
        compositeIndexSql += ' ON ';
        compositeIndexSql += AbstractDao.TABLENAME(entityCls);
        compositeIndexSql += ' (';
        for (let item of indexNameArr) {
          let property = propertiesArr.find((propertyItem) => {
            return propertyItem.name == item.value
          })
          if (property) {
            compositeIndexSql += property.columnName + item.order.replace('_', ' ') + ',';
          } else {
            console.error("Invalid SQL Statements form!");
            throw new Error("Invalid Statements!");
          }
        }
        compositeIndexSql = compositeIndexSql.substring(0, compositeIndexSql.length - 1);
        compositeIndexSql += ');';
        resultCompositeArr[i] = compositeIndexSql;
      }
    }
    return resultCompositeArr;
  }

  private static createSingleIndexSql<T>(ifNotExists: boolean, entityCls: T): string[] {
    const constraint = ifNotExists ? "IF NOT EXISTS " : " ";
    let resultSingleArr = [];
    let createIndexSql = '';
    let propertiesArr = AbstractDao.generatorProperties(entityCls);
    if (propertiesArr && propertiesArr.length > 0) {
      let i = 0;
      for (let property of propertiesArr) {
        if (property.index) {
          createIndexSql = 'CREATE ';
          let index_unique = property.index.unique;
          if (index_unique) {
            createIndexSql += 'UNIQUE ';
          }
          createIndexSql += 'INDEX ' + constraint;

          let index_name = property.index.name;
          if (index_name) {
            createIndexSql += index_name;
          } else {
            createIndexSql += 'IDX_' + AbstractDao.TABLENAME(entityCls) + '_';
            createIndexSql += property.columnName;
          }
          createIndexSql += ' ON ';
          createIndexSql += AbstractDao.TABLENAME(entityCls);
          createIndexSql += ' (' + property.columnName;

          createIndexSql += ' ASC';

          createIndexSql += ');';
          resultSingleArr[i] = createIndexSql;
          i++;
        }
      }
    }
    return resultSingleArr;
  }

  public static getCreateIndexSql<T>(ifNotExists: boolean, entityCls: T): string[] {

    //       示例 const constraint = ifNotExists ? "IF NOT EXISTS " : "";
    //       复合 delegate.execSQL("CREATE UNIQUE INDEX " + constraint + "IDX_NOTE_TEXT123_ASC_DATE_DESC ON \"NOTE\"" + " (\"TEXT123\" ASC,\"DATE\" DESC);");
    //       单个 delegate.execSQL("CREATE UNIQUE INDEX " + constraint + "IDX_NOTE_TYPE ON \"NOTE\"" +
    //        " (\"TYPE\" ASC);");

    let resultArr = [];
    let compositeArr = AbstractDao.createCompositeIndexSql(ifNotExists, entityCls);
    if (compositeArr && compositeArr.length > 0) {
      resultArr = compositeArr;
    }
    let singleArr = AbstractDao.createSingleIndexSql(ifNotExists, entityCls);
    if (singleArr && singleArr.length > 0) {
      resultArr.push(singleArr);
    }
    return resultArr;
  }
}

export class Properties {
}
