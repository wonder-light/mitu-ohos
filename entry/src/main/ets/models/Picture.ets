import { IDiscoverRule, IPictureSource, ISearchRule } from '../common/Interface';
import { DiscoverRule } from './rule/Discover';

/**
 * 图片模型
 */
@Observed
export class PictureSource implements IPictureSource {
  /** 图源ID */
  id?: number;
  /** 图源 */
  origin: string = '';
  /** 图源名称 */
  originName: string = '';
  /** PictureType */
  type?: string;
  /** 名称: 当前图片模型的名称 */
  name: string;
  /** 作者: 当前图片模型的作者 */
  author: string;
  /** 简介内容 */
  intro?: string;
  /** 分类 */
  kind?: string;
  /** 在导入的情况下或则未分组默认为 2 未分组 */
  group: number;
  /** 创建或更新时间 */
  time: number;
  /** 应用于动态参数或动态JS中的变量 */
  variable: string;
  /** 自定义变量说明 */
  variableComment?: string;
  /** 图源排序 */
  order: number;
  /** 是否置顶 */
  isTop: boolean;
  /** 是否隐藏 */
  isHide: boolean;
  /** 响应超时时间 */
  respondTime: number;
  /** 搜索规则 */
  searchRule?: ISearchRule;
  /** 发现规则 */
  discoverRule: IDiscoverRule;
  /** js库 */
  jsLib?: string;
  /** 启用 ok http Cookie 自动保存每次请求的cookie */
  enabledCookie: boolean;
  /** 并发率 */
  concurrentRate?: string;
  /** 请求头 */
  header?: string;
  /** 封面解密js, 依次向上回归 */
  decodeJs?: string;
  /** 图片样式, 默认大小居中, FULL最大宽度 */
  style?: string;
  /** 登录地址 */
  loginUrl?: string;
  /** 登录UI */
  loginUi?: string;
  /** 登录检测js */
  loginCheckJs?: string;

  constructor(item?: IPictureSource) {
    this.id = item?.id;
    this.origin = item?.origin ?? '';
    this.originName = item?.originName ?? '';
    this.type = item?.type;
    this.name = item?.name ?? '';
    this.author = item?.author ?? '';
    this.intro = item?.intro;
    this.kind = item?.kind;
    this.group = item?.group ?? 3;
    this.time = item?.time ?? Date.now();
    this.variable = item?.variable ?? '';
    this.variableComment = item?.variableComment;
    this.order = item?.order ?? 0;
    this.isTop = item?.isTop ?? false;
    this.isHide = item?.isHide ?? false;
    this.respondTime = item?.respondTime ?? -1;
    this.searchRule = item?.searchRule;
    this.discoverRule = item?.discoverRule ?? new DiscoverRule();
    this.jsLib = item?.jsLib;
    this.enabledCookie = item?.enabledCookie ?? true;
    this.concurrentRate = item?.concurrentRate;
    this.header = item?.header;
    this.decodeJs = item?.decodeJs;
    this.style = item?.style;
    this.loginUrl = item?.loginUrl;
    this.loginUi = item?.loginUi;
    this.loginCheckJs = item?.loginCheckJs;
  }
}