import { Columns, ColumnType, Entity } from '@ohos/dataorm';
import { ISearchRule } from '../../common/Interface';
import { BasicTable } from '../Base';

/**
 * 图源搜索规则
 */
@Observed
@Entity('SearchRule')
export class SearchRule extends BasicTable implements ISearchRule {
  @Columns({ columnName: 'urlRule', types: ColumnType.str })
  urlRule: string;
  @Columns({ columnName: 'nameRule', types: ColumnType.str })
  nameRule: string;
  @Columns({ columnName: 'authorRule', types: ColumnType.str })
  authorRule: string;
  @Columns({ columnName: 'introRule', types: ColumnType.str })
  introRule: string;
  @Columns({ columnName: 'kindRule', types: ColumnType.str })
  kindRule: string;
  @Columns({ columnName: 'listRule', types: ColumnType.str })
  listRule: string;
  @Columns({ columnName: 'thumbnailRule', types: ColumnType.str })
  thumbnailRule: string;
  @Columns({ columnName: 'detailRule', types: ColumnType.str })
  detailRule: string;

  constructor(item?: ISearchRule) {
    super(item?.id);
    this.urlRule = item?.urlRule ?? '';
    this.nameRule = item?.nameRule ?? '';
    this.authorRule = item?.authorRule ?? '';
    this.introRule = item?.introRule ?? '';
    this.kindRule = item?.kindRule ?? '';
    this.listRule = item?.listRule ?? '';
    this.thumbnailRule = item?.thumbnailRule ?? '';
    this.detailRule = item?.detailRule ?? '';
  }
}