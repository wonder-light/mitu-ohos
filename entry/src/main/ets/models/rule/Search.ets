import { ISearchRule } from '../../common/interface';

/**
 * 图源搜索规则
 */
@Observed
export class SearchRule implements ISearchRule {
  /** URL规则 */
  urlRule?: string;
  /** 名称规则 */
  nameRule?: string;
  /** 作者规则 */
  authorRule?: string;
  /** 简介规则 */
  introRule?: string;
  /** 分类规则 */
  kindRule?: string;
  /** 列表规则 */
  listRule?: string;
  /** 略缩图 URL 规则 */
  thumbnailRule?: string;
  /** 详情图 URL 规则: 有效时转到详情规则获取图片的原始大小URL */
  detailRule?: string;

  constructor(item?: ISearchRule) {
    this.urlRule = item?.urlRule;
    this.nameRule = item?.nameRule;
    this.authorRule = item?.authorRule;
    this.introRule = item?.introRule;
    this.kindRule = item?.kindRule;
    this.listRule = item?.listRule;
    this.thumbnailRule = item?.thumbnailRule;
    this.detailRule = item?.detailRule;
  }
}