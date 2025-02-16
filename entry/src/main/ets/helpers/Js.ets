import { JavaScriptInterface } from '@hzw/ohos-dsbridge';
import { Log } from '../utils';

/**
 * Js Bridge, 实现业务API , 通过类来集中统一管理AP
 */
export class JsBridge {
  /**
   * 同步
   * @param p
   * @returns
   */
  @JavaScriptInterface(false)
  testSync(p: string): string {
    Log.d("testSync: " + JSON.stringify(p))
    return "hello native"
  }
}