import { sendablePreferences } from '@kit.ArkData';
import { HashMap, worker } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { DaoSession } from '@ohos/dataorm';
import { DEBUG } from 'BuildProfile';
import { Const, IDiscoverRule, INavTransition, ISearchRule, IStage } from '../common';
import { PictureSource } from '../models';
import { DbHelper } from './Database';

/**
 * 站点的导航管理
 */
class SiteNavManage implements IStage<Promise<void>> {
  /**
   * 导航动画管理
   */
  protected navTransitions: HashMap<string, INavTransition> = new HashMap();

  constructor() {
  }

  public async initState(context: Context): Promise<void> { }

  public dispose(): void {
    this.navTransitions.clear();
  }

  /**
   * 注册导航页面转换动画
   * @param navDestinationId 导航 id
   * @param transition 导航页面转换动画接口
   */
  public registerNavTransition(navDestinationId: string, transition: INavTransition): void {
    this.navTransitions.set(navDestinationId, transition);
  }

  /**
   * 获取导航页面转换动画
   * @param navDestinationId 导航 id
   * @returns
   */
  public getNavTransition(navDestinationId?: string): INavTransition | undefined {
    if (this.navTransitions == null) return undefined;
    return this.navTransitions.get(navDestinationId);
  }

  /**
   * 注销导航页面转换动画
   * @param navDestinationId 导航 id
   */
  public unregisterNavTransition(navDestinationId: string): void {
    this.navTransitions.remove(navDestinationId);
  }
}

/**
 * 站点控制
 */
@Observed
export class Site extends SiteNavManage {
  /** 单例 */
  static readonly instance: Site = new Site();
  /** 后台线程 */
  declare background: worker.ThreadWorker;
  /** app 包名 */
  bundleName: string = '';
  /** 数据库 */
  declare db: DaoSession;
  /** 共享用户首选项 */
  declare pf: sendablePreferences.Preferences;

  // 私有化构造器
  private constructor() {
    super();
  }

  /** 站点数据初始化 */
  public async initState(context: Context): Promise<void> {
    await super.initState(context);
    // 初始化数据库
    await DbHelper.initialize(context);
    if (DEBUG) {
      await site._debug();
    }
    // 发出初始化事件
    emitter.emit(Const.siteInit);
  }

  /** 站点销毁 */
  public dispose(): void {
    super.dispose();
    this.pf.flushSync();
    this.background?.terminate();
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
    for (let i = 0; i < 10; i++) {
      const obj = getPicture(i);
      await site.db.insertOrReplace(obj.searchRule);
      await site.db.insertOrReplace(obj.discoverRule);
      await site.db.insertOrReplace(obj);
    }
  }
}

/**
 * 站点控制单例
 */
export const site = Site.instance;