/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Based on Property.java written by
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

import { SqlUtils } from './internal/SqlUtils';
import { WhereCondition } from './query/WhereCondition';
import { PropertyCondition } from './query/PropertyCondition';
import { StringBuilder } from './StringBuilder'
import { ConvertParameter } from './converter/ConvertParameter';
import { Queue } from './common/Queue';

export class Constraint {
  public orderBy: string;
  public uniques: boolean;
  public notNull: boolean;

  constructor() {

  }

  setOrderBy(orderBy: string) {
    this.orderBy = orderBy;
  }

  setUnique(uniques: boolean) {
    this.uniques = uniques;
  }

  setNotNull(notNull: boolean) {
    this.notNull = notNull;
  }
}

class Index {
  public unique: boolean;
  public name: string;
}

/**
 * Meta data describing a property mapped to a database column; used to create WhereCondition object used by the query builder.
 *
 * @author Markus
 */
export class Property {
  public ordinal: number;
  public type: string;
  public name: string;
  public primaryKey: boolean;
  public columnName: string;
  public constraint: Constraint;
  public autoincrement: boolean;
  public unionPrimaryKey: boolean;
  public index: Index;
  // Embedded 嵌套数据
  public sourcesPropertyArray: Queue<string>; // 嵌套对象的源属性名称

  // convert
  private convertParam: ConvertParameter;

  constructor(ordinal: number, type: string, name: string, primaryKey: boolean, columnName: string, autoincrement: boolean,
              sourcesPropertyName?: Queue<string>) {
    this.ordinal = ordinal;
    this.type = type;
    this.name = name;
    this.primaryKey = primaryKey;
    this.columnName = columnName;
    this.autoincrement = autoincrement;
    let queue = new  Queue<string>();
    if (sourcesPropertyName) {
      sourcesPropertyName.getElements().forEach((v, t) => {
        queue.add(v);
      });
    }
    this.sourcesPropertyArray = queue;
  }

  public setIndex(index: Index) {
    this.index = index;
  }

  public setUnionPrimaryKey(unionPrimaryKey: boolean) {
    this.unionPrimaryKey = unionPrimaryKey;
  }

  public setOrdinal(ordinal: number) {
    this.ordinal = ordinal;
  }

  public setConstraint(constraint: Constraint) {
    this.constraint = constraint;
  }

  /** Creates an "equal ('=')" condition  for this property. */
  public eq(value: any): WhereCondition {
    return new PropertyCondition(this, "eq", value);
  }

  public eqSql(value: any): WhereCondition {
    return new PropertyCondition(this, "=?", value);
  }

  /** Creates an "not equal ('&lt;&gt;')" condition  for this property. */
  public notEq(value: any): WhereCondition {
    return new PropertyCondition(this, "notEq", value);
  }

  public notEqSql(value: any): WhereCondition {
    return new PropertyCondition(this, "<>?", value);
  }

  /** Creates an "LIKE" condition  for this property. */
  public like(value: string): WhereCondition {
    return new PropertyCondition(this, "like", value);
  }

  public likeSql(value: string): WhereCondition {
    return new PropertyCondition(this, " LIKE ?", value);
  }

  /** Creates an "BETWEEN ... AND ..." condition  for this property. */
  public between(value1: any, value2: any): WhereCondition {
    let values: any[] = [value1, value2];
    return new PropertyCondition(this, "between", undefined, values);
  }

  public betweenSql(value1: any, value2: any): WhereCondition {
    let values: any[] = [value1, value2];
    return new PropertyCondition(this, " BETWEEN ? AND ?", undefined, values);
  }

  /** Creates an "IN (..., ..., ...)" condition  for this property. */
  public inData(...inValues: any[]): WhereCondition {
    inValues = inValues.flat(Infinity);
    return new PropertyCondition(this, "in", undefined, inValues);
  }

  public inDataSql(...inValues: any[]): WhereCondition {
    inValues = inValues.flat(Infinity);
    let condition = new StringBuilder(" IN (");
    SqlUtils.appendPlaceholders(condition.toString(), inValues.length).concat(')');
    return new PropertyCondition(this, condition.toString(), undefined, inValues);
  }

  /** Creates an "NOT IN (..., ..., ...)" condition  for this property. */
  public notIn(...notInValues: any[]): WhereCondition {
    notInValues = notInValues.flat(Infinity);
    return new PropertyCondition(this, "notIn", undefined, notInValues);
  }

  public notInSql(...notInValues: any[]): WhereCondition {
    notInValues = notInValues.flat(Infinity);
    let condition = new StringBuilder(" NOT IN (");
    SqlUtils.appendPlaceholders(condition.toString(), notInValues.length).concat(')');
    return new PropertyCondition(this, condition.toString(), undefined, notInValues);
  }

  /** Creates an "greater than ('&gt;')" condition  for this property. */
  public gt(value: any): WhereCondition {
    return new PropertyCondition(this, "gt", value);
  }

  public gtSql(value: any): WhereCondition {
    return new PropertyCondition(this, ">?", value);
  }

  /** Creates an "less than ('&lt;')" condition  for this property. */
  public lt(value: any): WhereCondition {
    return new PropertyCondition(this, "lt", value);
  }

  public ltSql(value: any): WhereCondition {
    return new PropertyCondition(this, "<?", value);
  }

  /** Creates an "greater or equal ('&gt;=')" condition  for this property. */
  public ge(value: any): WhereCondition {
    return new PropertyCondition(this, "ge", value);
  }

  public geSql(value: any): WhereCondition {
    return new PropertyCondition(this, ">=?", value);
  }

  /** Creates an "less or equal ('&lt;=')" condition  for this property. */
  public le(value: any): WhereCondition {
    return new PropertyCondition(this, "le", value);
  }

  public leSql(value: any): WhereCondition {
    return new PropertyCondition(this, "<=?", value);
  }

  /** Creates an "IS NULL" condition  for this property. */
  public isNull(): WhereCondition {
    return new PropertyCondition(this, "isNull");
  }

  public isNullSql(): WhereCondition {
    return new PropertyCondition(this, " IS NULL");
  }

  /** Creates an "IS NOT NULL" condition  for this property. */
  public isNotNull(): WhereCondition {
    return new PropertyCondition(this, "isNotNull");
  }

  public isNotNullSql(): WhereCondition {
    return new PropertyCondition(this, " IS NOT NULL");
  }

  setConvertParamObj(convertParam: ConvertParameter) {
    this.convertParam = convertParam;
  }

  getConvertParamObj(): ConvertParameter {
    return this.convertParam;
  }

  setSourcesPropertyArray(queue: Queue<string>) {
    this.sourcesPropertyArray = queue;
  }

  getSourcesPropertyArray(): Queue<string> {
    return this.sourcesPropertyArray;
  }
}
