import { PropertyConverter } from '@ohos/dataorm';
import { IDiscoverItemRule } from '../common/Interface';
import { DiscoverItemRule } from '../models';

export class JsonConverter<T> extends PropertyConverter<T, string> {
  newObj: (...args: Object[]) => T;

  constructor(type: (...args: Object[]) => T) {
    super();
    this.newObj = type;
  }

  /**
   * 将数据库数据转化成对应的集合或者数组
   * @param databaseValue 数据库存储的值
   * @returns
   */
  convertToEntityProperty(databaseValue: string): T {
    return this.newObj(JSON.parse(databaseValue)) as T;
  }

  /**
   * 将对象实体中集合或者数组数据转换为数据库存储的类型
   * @param entityProperty 对象实体
   * @returns
   */
  convertToDatabaseValue(entityProperty: T): string {
    return JSON.stringify(entityProperty);
  }
}

export class DiscoverItemsConverter extends JsonConverter<DiscoverItemRule[]> {
  constructor() {
    super((obj) => {
      let items = Array.isArray(obj) ? obj as Object[] : [];
      return items?.map(item => new DiscoverItemRule(item as IDiscoverItemRule)) ?? [];
    });
  }
}

