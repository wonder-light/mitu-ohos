/**
 * 图片详情URL规则
 */
export class DetailRule {
  /** 预处理规则 */
  init?: string;
  /** 名称规则 */
  name?: string;
  /** 作者规则 */
  author?: string;
  /** 简介规则 */
  intro?: string;
  /** 分类规则 */
  kind?: string;
  /** 下载URL规则 */
  download?: string;
  /** 封面解密js, 依次向上回归 */
  decodeJs?: string;
}