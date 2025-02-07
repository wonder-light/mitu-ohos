import { sendablePreferences } from '@kit.ArkData';
import { worker } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { DaoSession } from '@ohos/dataorm';
import { Const } from '../common';
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
  /** 搜图页面的初始图片源 */
  soutu?: PictureSource;

  // 私有化构造器
  private constructor() { }

  /**
   * 站点数据初始化
   * @param context
   * @returns
   */
  async initialize(context: Context): Promise<void> {
    await DbHelper.initialize(context);
    emitter.emit(Const.siteInit);
  }
}

/**
 * 站点控制单例
 */
export const site = Site.instance;