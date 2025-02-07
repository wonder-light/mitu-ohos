import { Columns, ColumnType, Convert, Entity, NotNull, Transient } from '@ohos/dataorm';
import { IDiscoverItemRule, IDiscoverRule } from '../../common/Interface';
import { DiscoverItemsConverter } from '../../utils';
import { SearchRule } from './Search';

/**
 * 图源发现项规则
 */
@Observed
export class DiscoverItemRule implements IDiscoverItemRule {
  /** 发现项名称 */
  name: string;
  /** URL规则 */
  urlRule?: string;
  /** 手动排序编号 */
  order: number;

  constructor(item?: IDiscoverItemRule) {
    this.name = item?.name ?? '';
    this.urlRule = item?.urlRule;
    this.order = item?.order ?? 0;
  }
}

/**
 * 图源发现规则
 */
@Observed
@Entity('DiscoverRule')
export class DiscoverRule extends SearchRule implements IDiscoverRule {
  /** 发现项 URL规则 */
  @NotNull(true)
  @Columns({ columnName: 'urlRules', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: DiscoverItemsConverter })
  urlRules: DiscoverItemRule[];

  constructor(item?: IDiscoverRule) {
    super(item);
    this.urlRules = item?.urlRules?.map(item => new DiscoverItemRule(item)) ?? [];
  }
}