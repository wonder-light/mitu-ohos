import { DaoMaster, Database, OpenHelper } from '@ohos/dataorm';
import { DiscoverRule, PictureSource, SearchRule } from '../models';
import { Log } from '../utils';
import { site } from './Site';

/**
 * 数据库选项帮助类
 */
export class DbHelper extends OpenHelper {
  /**
   * 初始化数据
   */
  static async initialize(context: Context, name: string = 'mitu.db'): Promise<void> {
    try {
      const dbHelper = new DbHelper(context, name);
      // 设定数据加密
      dbHelper.setEncrypt(false);
      // 设定数据库版本
      await dbHelper.setVersion(1);
      // 设定数据实体
      dbHelper.setEntities(DiscoverRule, SearchRule, PictureSource);
      // 数据库
      const db = await dbHelper.getWritableDb();
      site.db = new DaoMaster(db).newSession();
    } catch (e) {
      Log.e(`create dao session failed: ${JSON.stringify(e)}`);
    }
  }

  async onUpgradeDatabase(db: Database, oldVersion: number, newVersion: number): Promise<void> {
    Log.d(`on Upgrade Database oldVersion: ${oldVersion}, newVersion: ${newVersion}`);
    switch (oldVersion) {
      case 0:
        if (++oldVersion >= newVersion) break;
      default:
        break;
    }
  }

  async onDowngradeDatabase(db: Database, oldVersion: number, newVersion: number): Promise<void> {
    Log.d(`on Downgrade Database  oldVersion: ${oldVersion}, newVersion: ${newVersion}`);
    switch (oldVersion) {
      case 1: {
        await DaoMaster.dropAllTablesAsync(db, true);
        if (--oldVersion <= newVersion) break;
      }
      default:
        break;
    }
  }
}