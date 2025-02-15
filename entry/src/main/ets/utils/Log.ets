import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志
 */
export class Log {
  static readonly domain = 0xFF00;
  static readonly prefix = 'logger';
  private static _prefix?: string = undefined;

  /**
   * 设置日志前缀
   * @param prefix
   */
  static setPrefix(prefix: string) {
    Log._prefix = prefix;
  }

  /**
   * 打印调试信息
   * @param args
   */
  static d(...args: string[]) {
    hilog.debug(Log.domain, Log._prefix ?? Log.prefix, '%{public}s'.repeat(args.length), ...args);
    Log._prefix = undefined;
  }

  /**
   * 打印信息
   * @param args
   */
  static i(...args: string[]) {
    hilog.info(Log.domain, Log._prefix ?? Log.prefix, '%{public}s'.repeat(args.length), ...args);
    Log._prefix = undefined;
  }

  /**
   * 打印警告信息
   * @param args
   */
  static w(...args: string[]) {
    hilog.warn(Log.domain, Log._prefix ?? Log.prefix, '%{public}s'.repeat(args.length), ...args);
    Log._prefix = undefined;
  }

  /**
   * 打印错误信息
   * @param args
   */
  static e(...args: string[]) {
    hilog.error(Log.domain, Log._prefix ?? Log.prefix, '%{public}s'.repeat(args.length), ...args);
    Log._prefix = undefined;
  }
}