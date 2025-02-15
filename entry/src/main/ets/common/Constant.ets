/**
 * 常量
 */
export class Const {
  // ----------------------------------- 路由 -----------------------------------
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
  static readonly imgSourceManage: string = 'imgSourceManage';
  /** 图床源管理页面 */
  static readonly bedSourceManage: string = 'bedSourceManage';
  /** 关于页面 */
  static readonly about: string = 'about';
  /** 404 页面 */
  static readonly notFound: string = 'notFound';
  // ----------------------------------- 路由 -----------------------------------
  // ----------------------------------- 首选项键 -----------------------------------
  /** 搜索历史 */
  static readonly searchHistory: string = 'searchHistory';
  /** 历史数量 */
  static readonly historyCount = 100;
  /** 搜索页面选择的分组或源 */
  static readonly searchSelects: string = 'searchSelects';
  /** 主题模式 */
  static readonly themeMode: string = 'themeMode';
  // ----------------------------------- 首选项键 -----------------------------------
  // ----------------------------------- 事件 -----------------------------------
  /** 站点初始化完成 */
  static readonly siteInit: string = 'siteInit';
  // ----------------------------------- 事件 -----------------------------------
  // ----------------------------------- 参数 -----------------------------------
  /** 动画参数 */
  static readonly animate: AnimateParam = { duration: 200, curve: Curve.Ease };
  /** 动画参数 */
  static readonly animate3: AnimateParam = { duration: 300, curve: Curve.Ease };
  // ----------------------------------- 参数 -----------------------------------
  // ----------------------------------- 资源 -----------------------------------
  static readonly cFont: Resource = $r('app.color.font');
  static readonly cPrimary: Resource = $r('app.color.primary');
  static readonly cAccent: Resource = $r("app.color.accent");
  static readonly cIconOn: Resource = $r('app.color.icon_on');
  static readonly cBackground: Resource = $r('app.color.background');
  static readonly cButtonActive: Resource = $r('app.color.button_active');
  static readonly cButtonNormal: Resource = $r('app.color.button_normal');
  static readonly cButtonDivider: Resource = $r('app.color.button_divider');
  static readonly cFontSecondary: Resource = $r("app.color.fontSecondary");
  static readonly fTextXs: Resource = $r("app.float.text_xs");
  static readonly fTextSm: Resource = $r("app.float.text_sm");
  static readonly fTextXl: Resource = $r("app.float.text_xl");
  static readonly fIconSize: Resource = $r("app.float.icon_size");
  static readonly fIconSizeLg: Resource = $r("app.float.icon_size_lg");
  static readonly mArrowRight: Resource = $r("sys.media.ohos_ic_public_arrow_right");
  // ----------------------------------- 资源 -----------------------------------
}