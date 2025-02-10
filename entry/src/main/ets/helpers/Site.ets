import { sendablePreferences } from '@kit.ArkData';
import { worker } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { DaoSession } from '@ohos/dataorm';
import { DEBUG } from 'BuildProfile';
import { Const, IDiscoverRule, ISearchRule } from '../common';
import { PictureSource } from '../models';
import { DbHelper } from './Database';

/**
 * 站点控制
 */
@Observed
export class Site {
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
  private constructor() { }

  /**
   * 站点数据初始化
   * @param context
   * @returns
   */
  async initialize(context: Context): Promise<void> {
    await DbHelper.initialize(context);
    if (DEBUG) {
      await site._debug();
    }
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