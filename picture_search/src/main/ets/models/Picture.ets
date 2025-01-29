import { SourceItem } from './Source';

/**
 * 图片模型
 */
@Observed
export class PictureSource {
  /** 图源ID */
  id?: number;
  /** 图源 */
  origin: string = '';
  /** 图源名称 */
  originName: string = '';
  /** PictureType */
  type: string = '';
  /** 名称: 当前图片模型的名称 */
  name: string = '';
  /** 作者: 当前图片模型的作者 */
  author: string = '';
  /** 简介内容 */
  intro?: string;
  /** 分类 */
  kind?: string;
  /** 在导入的情况下或则未分组默认为 2 未分组 */
  group: number = 3;
  /** 创建或更新时间 */
  time: number = Date.now();
  /** 应用于动态参数或动态JS中的变量 */
  variable: string = '';
  /** 自定义变量说明 */
  variableComment?: string;
  /** 图源排序 */
  order?: number = 0;
  /** 是否置顶 */
  isTop: boolean = false;
  /** 是否隐藏 */
  isHide: boolean = false;
  /** 响应超时时间 */
  respondTime: number = -1;
  /** 源列表 */
  sourceList: SourceItem[] = [];
  /** js库 */
  jsLib?: string;
  /** 启用 ok http Cookie 自动保存每次请求的cookie */
  enabledCookie?: boolean = true;
  /** 并发率 */
  concurrentRate?: string;
  /** 请求头 */
  header?: string;
  /** 封面解密js, 依次向上回归 */
  decodeJs?: string;
  /** 登录地址 */
  loginUrl?: string;
  /** 登录UI */
  loginUi?: string;
  /** 登录检测js */
  loginCheckJs?: string;
}