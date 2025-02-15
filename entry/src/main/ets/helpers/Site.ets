import { bundleManager, common, ConfigurationConstant } from '@kit.AbilityKit';
import { sendablePreferences } from '@kit.ArkData';
import { HashMap, worker } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { DaoSession } from '@ohos/dataorm';
import { DEBUG } from 'BuildProfile';
import { Const, IDiscoverRule, INavTransition, ISearchRule, IStage } from '../common';
import { BedSource, PictureSource } from '../models';
import { DbHelper } from './Database';

/**
 * 站点基础
 */
class BaseSite implements IStage<void> {
  /** UI 上下文 */
  protected declare _context: common.UIAbilityContext;

  /** 设置 UI 上下文 */
  public set context(context: common.UIAbilityContext) {
    this._context = context;
  }

  /** 后台线程 */
  protected declare _background: worker.ThreadWorker;

  /** 后台线程 */
  public get background(): worker.ThreadWorker {
    return this._background;
  }

  /** app 包名 */
  protected declare _bundleName: string;

  /** app 包名 */
  public get bundleName(): string {
    return this._bundleName;
  }

  /** app 版本名 */
  protected declare _versionName: string;

  /** app 版本名, 1.*.0 */
  public get versionName(): string {
    return this._versionName;
  }

  /** 共享用户首选项 */
  protected declare _pf: sendablePreferences.Preferences;

  /** 共享用户首选项 */
  public get pf(): sendablePreferences.Preferences {
    return this._pf;
  }

  /** app 主题模式 */
  protected _themeMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;

  /** 获取 app 主题模式 */
  public get themeMode(): ConfigurationConstant.ColorMode {
    return this._themeMode;
  }

  /** 设置 app 主题模式 */
  public set themeMode(mode: ConfigurationConstant.ColorMode) {
    this._themeMode = mode;
    this._context.getApplicationContext().setColorMode(this._themeMode);
    this.pf.put(Const.themeMode, mode);
  }

  public initState(context: Context): void {
    // 设置后台线程
    this._background = new worker.ThreadWorker('entry/ets/workers/background.ets');
    // 指示用于指定将返回的BundleInfo对象中包含的信息的标志。
    const flags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
    // 获取包信息
    const info = bundleManager.getBundleInfoForSelfSync(flags);
    // com.nianian.mitu
    this._bundleName = info.name; // context.applicationInfo.name;
    this._versionName = info.versionName;
    // mitu
    const name = this._bundleName.split('.').pop()!;
    // 首选项
    this._pf = sendablePreferences.getPreferencesSync(context, { name: name });
    // 设置主题模式
    this._themeMode = this.pf.getSync(Const.themeMode, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET) as ConfigurationConstant.ColorMode;
  }

  /** 站点销毁 */
  public dispose(): void {
    this._pf.flushSync();
    this.background?.terminate();
  }
}

/**
 * 站点的导航管理
 */
class SiteNavManage extends BaseSite {
  /**
   * 导航动画管理
   */
  protected _navTransitions: HashMap<string, INavTransition> = new HashMap();

  constructor() {
    super();
  }

  public dispose(): void {
    super.dispose();
    this._navTransitions.clear();
  }

  /**
   * 注册导航页面转换动画
   * @param navDestinationId 导航 id
   * @param transition 导航页面转换动画接口
   */
  public registerNavTransition(navDestinationId: string, transition: INavTransition): void {
    this._navTransitions.set(navDestinationId, transition);
  }

  /**
   * 获取导航页面转换动画
   * @param navDestinationId 导航 id
   * @returns
   */
  public getNavTransition(navDestinationId?: string): INavTransition | undefined {
    if (this._navTransitions == null) return undefined;
    return this._navTransitions.get(navDestinationId);
  }

  /**
   * 注销导航页面转换动画
   * @param navDestinationId 导航 id
   */
  public unregisterNavTransition(navDestinationId: string): void {
    this._navTransitions.remove(navDestinationId);
  }
}

/**
 * 站点控制
 */
@Observed
export class Site extends SiteNavManage {
  /** 单例 */
  static readonly instance: Site = new Site();

  // 私有化构造器
  private constructor() {
    super();
  }

  /** 数据库 */
  protected declare _db: DaoSession;

  /** 数据库 */
  public get db(): DaoSession {
    return this._db;
  }

  /** 站点数据初始化 */
  public async initState(context: Context): Promise<void> {
    super.initState(context);
    // 初始化数据库
    this._db = await DbHelper.initialize(context);
    if (DEBUG) {
      await site._debug();
    }
    // 发出初始化事件
    emitter.emit(Const.siteInit);
  }

  private async _debug() {
    const search: ISearchRule = {
      urlRule: 'https://www.pixiv.net/search.php?s_mode=s_tag&word={keyword}',
      nameRule: '{keyword}'
    };
    const getDiscover = (id: number): IDiscoverRule => {
      let item: IDiscoverRule = { urlRules: [] };
      for (let name of ['必应', '百度', 'Pixiv']) {
        item.urlRules!.push({
          name: id + '-' + name,
          urlRule: 'https://cn.bing.com/images/search?q={keyword}&ensearch=1'
        });
      }
      return item;
    }
    const getPicture = (id: number): PictureSource => {
      return new PictureSource({
        id: id,
        origin: 'https://www.pixiv.net/' + id,
        originName: 'www.pixiv.net-' + id,
        name: 'Pixiv-' + id,
        group: 'pixiv,illustration,' + id,
        searchRule: search,
        discoverRule: getDiscover(id)
      });
    }
    const getBed = (id: number): BedSource => {
      return new BedSource({
        id: id,
        origin: 'https://www.pixiv.net/' + id,
        originName: 'www.pixiv.net-' + id,
        name: 'Pixiv-' + id,
        group: 'pixiv,illustration,' + id,
        albumRule: {},
        imageRule: {}
      });
    }
    for (let i = 0; i < 10; i++) {
      const obj = getPicture(i);
      await site.db.insertOrReplace(obj.searchRule);
      await site.db.insertOrReplace(obj.discoverRule);
      await site.db.insertOrReplace(obj);
      const bed = getBed(i);
      await site.db.insertOrReplace(bed.albumRule);
      await site.db.insertOrReplace(bed.imageRule);
      await site.db.insertOrReplace(bed);
    }
  }
}

/**
 * 站点控制单例
 */
export const site = Site.instance;