/**
 * 图片单个源的规则
 */
@Observed
export class SourceItem {
  /** 名称: 当前源项的名称 */
  name: string = '';
  /** 注释 */
  comment?: string;
  /** 是否启用 */
  enabled: boolean = true;
  /** URL规则 */
  urlRule?: string;
  /** 列表规则 */
  listRule?: string;
  /** 名称规则 */
  nameRule?: string;
  /** 作者规则 */
  authorRule?: string;
  /** 简介规则 */
  introRule?: string;
  /** 分类规则 */
  kindRule?: string;
  /** 详情URL规则: 有效时转到详情规则获取图片的原始大小URL */
  detailRule?: string;
  /** 下一页规则 */
  nextUrlRule?: string;
  /** 封面解密js, 依次向上回归 */
  decodeJs?: string;
  /** 图片样式, 默认大小居中, FULL最大宽度 */
  style?: string;
  /** 手动排序编号 */
  order: number = 0;
}