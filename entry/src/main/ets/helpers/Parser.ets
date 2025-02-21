import { collections, lang } from '@kit.ArkTS';
import { TAny, TRecord } from '../common';
import { site } from './Site';
import { task } from './Task';

'use shared'

@Sendable
class ParserType implements lang.ISendable {
  /** Url 类型 */
  public readonly url: string = 'url';
  /** Xpath 类型 */
  public readonly xpath: string = 'xpath';
  /** jsonpath 类型 */
  public readonly json: string = 'json';
  /** jsonpath 类型 */
  public readonly jsonpath: string = 'jsonpath';
  /** javascript 类型 */
  public readonly js: string = 'js';
  /** javascript 类型 */
  public readonly javascript: string = 'javascript';
  /** 规则类型集合 */
  public readonly ruleSet: collections.Set<string> = new collections.Set([
    this.url, this.xpath, this.json, this.jsonpath, this.js, this.javascript
  ]);

  /** 一个布尔值，指示具有指定值的元素是否存在于集合中*/
  public has(type: string): boolean {
    return this.ruleSet.has(type);
  }
}

/**
 * 规则解析器
 */
@Sendable
export class Parser implements lang.ISendable {
  /** 单例 */
  static readonly instance: Parser = new Parser();
  // ------------------- 字符串常量 ---------------------
  static readonly url: string = 'url';
  static readonly xpath: string = 'xpath';
  static readonly json: string = 'json';
  static readonly jsonpath: string = 'jsonpath';
  static readonly js: string = 'js';
  static readonly javascript: string = 'javascript';
  /**
   * 规则类型集合
   */
  public readonly types: ParserType = new ParserType();

  // 私有化构造器
  private constructor() { }

  /**
   * 解析 URL 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseUrl(rule: string, context: TRecord): Promise<string> {
    return this.parse(rule, context, this.types.url);
  }

  /**
   * 解析 XPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseXpath(rule: string, context: TRecord): Promise<string> {
    return this.parse(rule, context, this.types.xpath);
  }

  /**
   * 解析 JSONPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseJsonpath(rule: string, context: TRecord): Promise<string> {
    return this.parse(rule, context, this.types.json);
  }

  /**
   * 解析 javascript 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseJs(rule: string, context: TRecord): Promise<string> {
    return this.parse(rule, context, this.types.js);
  }

  /**
   * 解析字符串规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parse(rule: string, context: TRecord, defaultParse?: string): Promise<string> {
    // 替换插值变量 {{_}}
    let replacer = (match: string, key: string): string => {
      try {
        return JSON.stringify(context[key]) ?? '';
      } catch (e) {
        return '';
      }
    };
    // 按照类型分割段落
    const rules = rule.split(/$^([\r\n]+\s*)+/g);
    for (let item of rules) {
      // 替换插值变量 {{_}}
      item = item.replace(/\{\{(.*?)\}\}/g, replacer);
      // 获取规则类型
      let type = (item.match(/\@(.*)\:/) ?? [])[1];
      if (!this.types.has(type)) {
        type = defaultParse ?? this.types.js;
      }
      // 各个规则对应的解析器
      switch (type) {
        case this.types.js:
        case this.types.javascript:
          await this.parseJsImpl(item, context);
          break;
        case this.types.xpath:
          await this.parseXpathImpl(item, context);
          break;
        case this.types.json:
        case this.types.jsonpath:
          await this.parseJsonpathImpl(item, context);
          break;
        case this.types.url:
          await this.parseUrlImpl(item, context);
          break;
      }
    }
    // 执行 eval
    return 'parse'
  }

  /**
   * 解析 URL 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseUrlImpl(rule: string, context: TRecord): Promise<TRecord> {
    let items = rule.trim().replace(/,\s*(?=\{)/, '@@@@').split('@@@@')
    // 选项
    let options: TRecord = {};
    try {
      let value: TAny = JSON.parse(items[1]);
      if (typeof value === 'object') {
        options = value;
      }
    } catch (e) { }
    // URL
    let url = items[0];
    if (url.endsWith(',')) url = url.substring(0, url.length - 1);
    // http
    let response = await task.get(url, options);
    if (response.responseCode < 400) {
      // 结果类型为 string | Object | ArrayBuffer
      context.result = response.result;
    } else {
      throw new Error(`请求 URL 失败, 响应代码: ${response.responseCode}, 结果: ${response.result}`);
    }
    return context;
  }

  /**
   * 解析 XPath 规则
   * @param rule 规则
   * @param context 上下文
   * @param isHtml 解析的结果是否尽可能的返回 HTML 字符串
   * @returns
   * @implements
   */
  protected async parseXpathImpl(rule: string, context: TRecord, isHtml: boolean = false): Promise<TRecord> {
    context.result = await site.js.htmlPath(context.result as string, rule, isHtml);
    return context
  }

  /**
   * 解析 JSONPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseJsonpathImpl(rule: string, context: TRecord): Promise<TRecord> {
    context.result = await site.js.jsonPath(context.result, rule);
    return context
  }

  /**
   * 解析 javascript 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseJsImpl(rule: string, context: TRecord): Promise<TRecord> {
    // 执行 js 代码
    let value = await site.js.exeEval(rule, context) as Object;
    context.result = value;
    //let value = await site.web.runJavaScript(`eval(${rule})`);
    return context;
  }
}

/**
 * 规则解析器单例
 */
export const parser = Parser.instance;