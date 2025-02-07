import { PropertyConverter } from '@ohos/dataorm';
import { IDiscoverItemRule } from '../common/Interface';
import { DiscoverItemRule } from '../models';

export abstract class JsonConverter<T> extends PropertyConverter<T, string> {
  /**
   * 将数据库数据转化成对应的集合或者数组
   * @param databaseValue 数据库存储的值
   * @returns
   */
  convertToEntityProperty(databaseValue: string): T {
    return this.newObj(this.fromJson(databaseValue));
  }

  /**
   * 将对象实体中集合或者数组数据转换为数据库存储的类型
   * @param entityProperty 对象实体
   * @returns
   */
  convertToDatabaseValue(entityProperty: T): string {
    return JSON.stringify(entityProperty);
  }

  /**
   * 创建对象
   * @param args
   * @returns
   */
  protected abstract newObj(...args: Object[]): T;

  /**
   * 将字符串转换为对象
   * @param str
   * @returns
   */
  protected fromJson(str: string): Object {
    try { return JSON.parse(str) ?? new Object } catch (e) { return new Object }
  }
}

export class BoolConverter extends JsonConverter<boolean> {
  newObj(obj: Object): boolean {
    return typeof obj === 'boolean' ? obj : false
  }
}

export class DiscoverItemsConverter extends JsonConverter<DiscoverItemRule[]> {
  newObj(obj: Object): DiscoverItemRule[] {
    let items = Array.isArray(obj) ? obj as Object[] : [];
    return items?.map(item => new DiscoverItemRule(item as IDiscoverItemRule)) ?? [];
  }
}

/**
 * TODO: @ohos/dataorm 变更
 * 文件 : @ohos/dataorm/src/main/ets/core/BaseDao.ts
 * 行数 : 358 行, protected loadCurrentDeep(resultSet: any, lock: boolean): T
 * 修改 :
 *
 * let toOne = entities.toOneRelations[i]
 * let dao = this.getSession().getDao(toOne.targetEntityClsName);
 * let customer = this.loadCurrentOther(dao, resultSet, offset);
 * if (customer != null || customer != undefined) {
 *   entity[toOne.name] = customer;
 * }
 * offset += dao.getAllColumns().length;
 */