import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志
 */
export default class Log {
  static readonly domain = 0xFF00;
  static readonly prefix = 'logger';

  /**
   * 打印调试信息
   * @param args
   */
  static d(...args: string[]) {
    hilog.debug(Log.domain, Log.prefix, '%{public}s'.repeat(args.length), ...args);
  }

  /**
   * 打印信息
   * @param args
   */
  static i(...args: string[]) {
    hilog.info(Log.domain, Log.prefix, '%{public}s'.repeat(args.length), ...args);
  }

  /**
   * 打印警告信息
   * @param args
   */
  static w(...args: string[]) {
    hilog.warn(Log.domain, Log.prefix, '%{public}s'.repeat(args.length), ...args);
  }

  /**
   * 打印错误信息
   * @param args
   */
  static e(...args: string[]) {
    hilog.error(Log.domain, Log.prefix, '%{public}s'.repeat(args.length), ...args);
  }
}