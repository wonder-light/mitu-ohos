import { Columns, ColumnType, Entity } from '@ohos/dataorm';
import { ISearchRule } from '../../common/Interface';
import { TableBasic } from '../TableBasic';

/**
 * 图源搜索规则
 */
@Observed
@Entity('SearchRule')
export class SearchRule extends TableBasic implements ISearchRule {
  /** URL规则 */
  @Columns({ columnName: 'urlRule', types: ColumnType.str })
  urlRule: string;
  /** 名称规则 */
  @Columns({ columnName: 'nameRule', types: ColumnType.str })
  nameRule: string;
  /** 作者规则 */
  @Columns({ columnName: 'authorRule', types: ColumnType.str })
  authorRule: string;
  /** 简介规则 */
  @Columns({ columnName: 'introRule', types: ColumnType.str })
  introRule: string;
  /** 分类规则 */
  @Columns({ columnName: 'kindRule', types: ColumnType.str })
  kindRule: string;
  /** 列表规则 */
  @Columns({ columnName: 'listRule', types: ColumnType.str })
  listRule: string;
  /** 略缩图 URL 规则 */
  @Columns({ columnName: 'thumbnailRule', types: ColumnType.str })
  thumbnailRule: string;
  /** 详情图 URL 规则: 有效时转到详情规则获取图片的原始大小URL */
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