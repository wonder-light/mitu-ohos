import { Columns, ColumnType, Convert, Entity, NotNull } from '@ohos/dataorm';
import { Const, IDiscoverRule } from '../../common';
import { DiscoverItemsConverter } from '../../utils';
import { DiscoverItemRule } from './DiscoverItem';
import { SearchRule } from './Search';

/**
 * 图源发现规则
 */
@Observed
@Entity(Const.tDiscoverRule)
export class DiscoverRule extends SearchRule implements IDiscoverRule {
  @NotNull(true)
  @Columns({ columnName: 'urlRules', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: DiscoverItemsConverter })
  urlRules: DiscoverItemRule[];

  constructor(item?: IDiscoverRule) {
    super(item);
    this.urlRules = item?.urlRules?.map(item => new DiscoverItemRule(item)) ?? [];
  }
}