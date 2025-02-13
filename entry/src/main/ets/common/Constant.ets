/**
 * 常量
 */
export class Const {
  /** 搜图页面 */
  static readonly soutu: string = 'soutu';
  /** 相册页面 */
  static readonly album: string = 'album';
  /** 仓库页面 */
  static readonly repo: string = 'repo';
  /** 设置页面 */
  static readonly setting: string = 'setting';
  /** 搜索页面 */
  static readonly search: string = 'search';
  /** 图源管理页面 */
  static readonly sourceManage: string = 'sourceManage';
  /** 404 页面 */
  static readonly notFound: string = 'notFound';

  /** 搜索历史 */
  static readonly searchHistory: string = 'searchHistory';
  /** 历史数量 */
  static readonly historyCount = 100;

  /** 搜索页面选择的分组或源 */
  static readonly searchSelects: string = 'searchSelects';


  /** 站点初始化完成 */
  static readonly siteInit: string = 'siteInit';

  /** 动画参数 */
  static readonly animate: AnimateParam = { duration: 200, curve: Curve.Ease };
  /** 动画参数 */
  static readonly animate3: AnimateParam = { duration: 300, curve: Curve.Ease };
}