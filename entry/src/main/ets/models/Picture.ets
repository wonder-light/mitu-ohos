import { Columns, ColumnType, Convert, Entity, Index, ToOne } from '@ohos/dataorm';
import { TableBasic } from '.';
import { IPictureSource } from '../common/Interface';
import { BoolConverter } from '../utils';
import { DiscoverRule } from './rule/Discover';
import { SearchRule } from './rule/Search';

/**
 * 图片模型
 */
@Observed
@Entity('PictureSource')
export class PictureSource extends TableBasic implements IPictureSource {
  /** 图源 */
  @Index()
  @Columns({ columnName: 'origin', types: ColumnType.str })
  origin: string = '';
  /** 图源名称 */
  @Index()
  @Columns({ columnName: 'originName', types: ColumnType.str })
  originName: string = '';
  /** PictureType */
  @Columns({ columnName: 'type', types: ColumnType.str })
  type: string;
  /** 名称: 当前图片模型的名称 */
  @Columns({ columnName: 'name', types: ColumnType.str })
  name: string;
  /** 作者: 当前图片模型的作者 */
  @Columns({ columnName: 'author', types: ColumnType.str })
  author: string;
  /** 简介内容 */
  @Columns({ columnName: 'intro', types: ColumnType.str })
  intro: string;
  /** 分类 */
  @Columns({ columnName: 'kind', types: ColumnType.str })
  kind: string;
  /** 在导入的情况下或则未分组默认为 2 未分组 */
  @Columns({ columnName: 'groups', types: ColumnType.num })
  group: string;
  /** 创建或更新时间 */
  @Columns({ columnName: 'time', types: ColumnType.num })
  time: number;
  /** 应用于动态参数或动态JS中的变量 */
  @Columns({ columnName: 'variable', types: ColumnType.str })
  variable: string;
  /** 自定义变量说明 */
  @Columns({ columnName: 'variableComment', types: ColumnType.str })
  variableComment: string;
  /** 图源排序 */
  @Columns({ columnName: 'orders', types: ColumnType.num })
  order: number;
  /** 是否置顶 */
  @Columns({ columnName: 'isTop', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: BoolConverter })
  isTop: boolean;
  /** 是否隐藏 */
  @Columns({ columnName: 'isHide', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: BoolConverter })
  isHide: boolean;
  /** 响应超时时间 */
  @Columns({ columnName: 'respondTime', types: ColumnType.num })
  respondTime: number;
  /** 搜索规则 */
  /** js库 */
  @Columns({ columnName: 'jsLib', types: ColumnType.str })
  jsLib: string;
  /** 启用 ok http Cookie 自动保存每次请求的cookie */
  @Columns({ columnName: 'enabledCookie', types: ColumnType.real })
  enabledCookie: boolean;
  /** 并发率 */
  @Columns({ columnName: 'concurrentRate', types: ColumnType.str })
  concurrentRate: string;
  /** 请求头 */
  @Columns({ columnName: 'header', types: ColumnType.str })
  header: string;
  /** 封面解密js, 依次向上回归 */
  @Columns({ columnName: 'decodeJs', types: ColumnType.str })
  decodeJs: string;
  /** 图片样式, 默认大小居中, FULL最大宽度 */
  @Columns({ columnName: 'style', types: ColumnType.str })
  style: string;
  /** 登录地址 */
  @Columns({ columnName: 'loginUrl', types: ColumnType.str })
  loginUrl: string;
  /** 登录UI */
  @Columns({ columnName: 'loginUi', types: ColumnType.str })
  loginUi: string;
  /** 登录检测js */
  @Columns({ columnName: 'loginCheckJs', types: ColumnType.str })
  loginCheckJs: string;
  @ToOne({ joinProperty: 'id', targetObj: SearchRule })
  searchRule: SearchRule;
  /** 发现规则 */
  @ToOne({ joinProperty: 'id', targetObj: DiscoverRule })
  discoverRule: DiscoverRule;

  constructor(item?: IPictureSource) {
    super(item?.id);
    this.origin = item?.origin ?? '';
    this.originName = item?.originName ?? '';
    this.type = item?.type ?? '';
    this.name = item?.name ?? '';
    this.author = item?.author ?? '';
    this.intro = item?.intro ?? '';
    this.kind = item?.kind ?? '';
    this.group = item?.group ?? '';
    this.time = item?.time ?? Date.now();
    this.variable = item?.variable ?? '';
    this.variableComment = item?.variableComment ?? '';
    this.order = item?.order ?? 0;
    this.isTop = item?.isTop ?? false;
    this.isHide = item?.isHide ?? false;
    this.respondTime = item?.respondTime ?? -1;
    this.jsLib = item?.jsLib ?? '';
    this.enabledCookie = item?.enabledCookie ?? true;
    this.concurrentRate = item?.concurrentRate ?? '';
    this.header = item?.header ?? '';
    this.decodeJs = item?.decodeJs ?? '';
    this.style = item?.style ?? '';
    this.loginUrl = item?.loginUrl ?? '';
    this.loginUi = item?.loginUi ?? '';
    this.loginCheckJs = item?.loginCheckJs ?? '';
    let search = item?.searchRule ?? {};
    search.id = this.id;
    this.searchRule = new SearchRule(search);
    let discover = item?.discoverRule ?? {};
    discover.id = this.id;
    this.discoverRule = new DiscoverRule(discover);
  }
}