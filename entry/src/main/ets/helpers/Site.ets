import { DataKvUtil } from '@abner/datastore';
import { worker } from '@kit.ArkTS';

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
  /** app 包名 */
  declare kv: DataKvUtil;

  // 私有化构造器
  private constructor() { }
}

/**
 * 站点控制单例
 */
export const site = Site.instance;