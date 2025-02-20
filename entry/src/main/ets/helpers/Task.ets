import { taskpool } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { HttpMethod } from '../common';
import { Log } from '../utils';
import { parser } from './Parser';

/**
 * 任务
 */
export namespace task {
  @Concurrent
  export async function run(context: Context) {
    try {
      Log.d('task.run initialize')
      Log.d('task.run context: ', typeof context)
      Log.d('task.run: ', await parser.parse(`current+1`, { 'current': 5 }))
    } catch (e) {
      Log.e(`task.run error: ${e}`)
    }
  }

  /**
   * 执行 HTTP 请求 - 实现
   * @param method 方法
   * @param url 地址
   * @param options 选项
   * @returns 结果
   */
  @Concurrent
  async function requestImpl(method: HttpMethod, url: string, options: http.HttpRequestOptions = {}): Promise<http.HttpResponse> {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息。
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)
    options.method ??= http.RequestMethod[method];
    options.header = options.header || {};
    return await httpRequest.request(url, options);
  }

  /**
   * 执行 HTTP 请求
   * @param method 方法
   * @param url 地址
   * @param options 选项
   * @returns 结果
   */
  export async function request(method: HttpMethod, url: string, options?: http.HttpRequestOptions): Promise<http.HttpResponse> {
    options ??= {};
    return await execLong(requestImpl, method, url, options) as http.HttpResponse;
  }

  /**
   * 执行 GET 请求
   * @param url 地址
   * @param options 选项
   * @returns 结果
   */
  export async function get(url: string, options?: http.HttpRequestOptions): Promise<http.HttpResponse> {
    return await request('GET', url, options);
  }

  /**
   * 执行长时任务
   * @param func 函数
   * @param args 参数
   * @returns 结果
   */
  export async function execLong(func: Function, ...args: Object[]): Promise<Object> {
    const long = new taskpool.LongTask(func, ...args);
    let value = await taskpool.execute(long);
    taskpool.terminateTask(long);
    return value;
  }

  /**
   * 执行短时任务
   * @param func 函数
   * @param args 参数
   * @returns 结果
   */
  export async function exec(func: Function, ...args: Object[]): Promise<Object> {
    return await taskpool.execute(new taskpool.Task(func, ...args));
  }
}