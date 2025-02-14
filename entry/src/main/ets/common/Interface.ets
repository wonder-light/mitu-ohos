/**
 * 表格基础
 */
export interface IBasicTable {
  id?: number;
}

/**
 * 图源搜索结果项接口, 搜索结果的最小单位
 */
export interface ISearchResultItem {
  /** 略缩图 URL */
  thumbnail?: string;

  /** 原始图 URL */
  origin: string;

  /** 名称 */
  name?: string;

  /** 作者 */
  author?: string;

  /** 简介 */
  intro?: string;

  /** 分类 */
  kind?: string[];
}

/**
 * 图源基础规则接口
 */
export interface IBaseRule extends IBasicTable {
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
}

/**
 * 图源搜索结果接口
 */
export interface ISearchRule extends IBaseRule {
  /** 列表规则 */
  listRule?: string;

  /** 略缩图 URL 规则 */
  thumbnailRule?: string;

  /** 详情图 URL 规则: 有效时转到详情规则获取图片的原始大小URL */
  detailRule?: string;
}

/**
 * 图源详情规则接口
 */
export interface IDetailRule extends IBaseRule {
  /** 预处理规则 */
  initRule?: string;
}

/**
 * 图源发现项规则接口
 */
export interface IDiscoverItemRule {
  /** 发现项名称 */
  name: string;

  /** URL规则 */
  urlRule?: string;

  /** 手动排序编号 */
  order?: number;
}

/**
 * 图源发现规则接口
 */
export interface IDiscoverRule extends ISearchRule {
  /** 发现项 URL规则 */
  urlRules?: IDiscoverItemRule[];

  /**
   * 发现项 URL规则
   * @deprecated 其使用 urlRules 代替
   */
  urlRule?: string;
}

/**
 * 基础源接口
 */
export interface IBaseSource extends IBasicTable {
  /** 源的基础 URL */
  origin?: string;

  /** 源的名称 */
  originName?: string;

  /** 名称: 当前使用的源的名称 */
  name?: string;

  /** 作者: 当前源的作者 */
  author?: string;

  /** 源的简介内容 */
  intro?: string;

  /** 在导入的情况下或则未分组默认为未分组 */
  group?: string;

  /** 创建或更新时间 */
  time?: number;

  /** 应用于动态参数或动态JS中的变量 */
  variable?: string;

  /** 自定义变量说明 */
  variableComment?: string;

  /** js库 */
  jsLib?: string;

  /** 源的排序 */
  order?: number;

  /** 是否置顶 */
  isTop?: boolean;

  /** 是否隐藏 */
  isHide?: boolean;

  /** 响应超时时间 */
  respondTime?: number;

  /** 启用 ok http Cookie Jar 自动保存每次请求的 cookie */
  enabledCookie?: boolean;

  /** 并发率 */
  concurrentRate?: string;

  /** 请求头 */
  header?: string;

  /** 封面解密js, 依次向上回退 */
  decodeJs?: string;

  /** 图片样式, 默认大小居中, FULL最大宽度 */
  style?: string;

  /** 登录地址 */
  loginUrl?: string;

  /** 登录UI */
  loginUi?: string;

  /** 登录检测js */
  loginCheckJs?: string;
}

/**
 * 图片模型接口
 */
export interface IPictureSource extends IBaseSource {
  /** 搜索规则 */
  searchRule?: ISearchRule;

  /** 发现规则 */
  discoverRule?: IDiscoverRule;
}

/**
 * 相册规则接口
 */
export interface IAlbumRule extends IBasicTable {
  /** 获取相册列表的规则 */
  listRule?: string;

  /** 创建相册列表的规则 */
  createRule?: string;

  /** 删除相册列表的规则 */
  deleteRule?: string;
}

/**
 * 图片规则接口
 */
export interface IImageRule extends IBaseSource {
  /** 获取图片列表的规则 */
  listRule?: string;

  /** 上传图片的规则 */
  uploadRule?: string;

  /** 删除图片的规则 */
  deleteRule?: string;
}

/**
 * 图床源接口
 */
export interface IBedSource extends IBaseSource {
  /** 相册规则 */
  albumRule?: IAlbumRule;

  /** 图片规则 */
  imageRule?: IImageRule;
}


/**
 * 阶段接口
 */
export interface IStage<T = void> {
  /** 初始化状态 */
  initState(context: Context): T;

  /** 释放 */
  dispose(): void;
}

/**
 * 导航页面转换动画接口
 */
export interface INavTransition {
  /** 动画开始前执行, 用于设置初始值 */
  onInit: (isExit: boolean) => void;

  /** 动画目标状态, 用于设置终点值 */
  onEnd: (isExit: boolean) => void;
}