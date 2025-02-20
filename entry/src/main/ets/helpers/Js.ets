import { JavaScriptInterface } from '@hzw/ohos-dsbridge';
import { TAny } from '../common/Type';
import { Log } from '../utils';
import { site } from './Site';

/**
 * Ets Bridge, 注册可以在 JS 中调用的函数
 */
export class EtsBridge {
  /** 日志 - info */
  @JavaScriptInterface(false)
  public info(args: string[]): void {
    Log.setPrefix("JsBridge")
    Log.d(...args)
  }

  /** 日志 - warn */
  @JavaScriptInterface(false)
  public warn(args: string[]): void {
    Log.setPrefix("JsBridge")
    Log.w(...args)
  }

  /** 日志 - error */
  @JavaScriptInterface(false)
  public error(args: string[]): void {
    Log.setPrefix("JsBridge")
    Log.e(...args)
  }
}

/**
 * 注册在 ETS 中调用的函数
 */
export class JsBridge {
  /**
   * 判断是否是错误
   * @param result 结果
   * @returns
   */
  private static isError(result: TAny): boolean {
    return result.error === true && result.stack;
  }

  /** 执行 JS 代码 */
  public async exeEval(code: string, context?: Record<string, Object>): Promise<TAny> {
    if (context) {
      // 添加上下文
      let prefix = ''
      for (const key of Object.keys(context)) {
        prefix += `let ${key}=${JSON.stringify(context[key])};\n`
      }
      code = prefix + '\n' + code;
    }
    return await new Promise<TAny>((resolve, reject) => {
      site.web.callJs('js.exeEval', [code], (result: TAny) => {
        if (JsBridge.isError(result)) return reject(result);
        resolve(result);
      })
    });
  }

  /** 添加 JS 库 */
  public async addLibs(jsLib: string): Promise<void> {
    // 获取 js 库
    let libs = jsLib.trim().split(/[;,\n]+/);
    if (libs.length <= 0) return;
    return await new Promise<void>((resolve, reject) => {
      site.web.callJs('js.addLibs', [libs], (result: TAny) => {
        if (JsBridge.isError(result)) return reject(result);
        resolve();
      })
    });
  }
}