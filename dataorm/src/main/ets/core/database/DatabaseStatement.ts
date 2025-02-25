/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Based on DatabaseStatement.java written by
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

// @ts-nocheck
import { SQLiteStatement } from './SQLiteStatement'
import relationalStore from '@ohos.data.relationalStore'

export interface DatabaseStatement {
  executeDelete(): Promise<number>;

  executeUpdate(conflictResolution?: relationalStore.ConflictResolution): Promise<number>;

  executeInsert(conflictResolution?: relationalStore.ConflictResolution): Promise<number>;

  bindString(index: number, value: string);

  bindValue(key: string, value: any);

  bindBlob(index: number, value: any);

  bindLong(index: number, value: number);

  clearBindings();

  bindDouble(index: number, value: number);

  getRawStatement(): SQLiteStatement;
}