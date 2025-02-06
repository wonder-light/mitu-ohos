import { worker } from '@kit.ArkTS';
import { DaoSession } from '@ohos/dataorm';

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

  // 私有化构造器
  private constructor() { }
}

/**
 * 站点控制单例
 */
export const site = Site.instance;