import { collections, lang } from '@kit.ArkTS';
import { site, task } from '.';
import { Log } from '../utils';

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
  public has(type: string) {
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
  public async parseUrl(rule: string, context: Record<string, Object>): Promise<string> {
    return this.parse(rule, context, this.types.url);
  }

  /**
   * 解析 XPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseXpath(rule: string, context: Record<string, Object>): Promise<string> {
    return this.parse(rule, context, this.types.xpath);
  }

  /**
   * 解析 JSONPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseJsonpath(rule: string, context: Record<string, Object>): Promise<string> {
    return this.parse(rule, context, this.types.json);
  }

  /**
   * 解析 javascript 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parseJs(rule: string, context: Record<string, Object>): Promise<string> {
    return this.parse(rule, context, this.types.js);
  }

  /**
   * 解析字符串规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   */
  public async parse(rule: string, context: Record<string, Object>, defaultParse?: string): Promise<string> {
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
      Log.d('rule: ', item);
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
  protected async parseUrlImpl(rule: string, context: Record<string, Object>): Promise<string> {
    let items = rule.trim().replace(/,\s*(?=\{)/, '@@@@').split('@@@@')
    let url = items[0];
    let options: Record<string, Object>;
    try {
      options = JSON.parse(items[1]) ?? {};
    } catch (e) {
      options = {};
    }
    if (url.endsWith(',')) url = url.substring(0, url.length - 1);
    let response = await task.get(url, options);

    return 'parseUrl'
  }

  /**
   * 解析 XPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseXpathImpl(rule: string, context: Record<string, Object>): Promise<string> {
    Log.d('rule Xpath: ');
    return 'parseUrl'
  }

  /**
   * 解析 JSONPath 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseJsonpathImpl(rule: string, context: Record<string, Object>): Promise<string> {
    Log.d('rule Jsonpath: ');
    return 'parseUrl'
  }

  /**
   * 解析 javascript 规则
   * @param rule 规则
   * @param context 上下文
   * @returns
   * @implements
   */
  protected async parseJsImpl(rule: string, context: Record<string, Object>): Promise<string> {
    try {
      let value = await site.js.exeEval(rule, context) as Object;
      Log.d('rule javascript: ', JSON.stringify(value));
      //let value = await site.web.runJavaScript(`eval(${rule})`);
    } catch (e) {
      Log.e('rule javascript: ', JSON.stringify(e, null, 2));
    }
    return 'parseUrl'
  }
}

/**
 * 规则解析器单例
 */
export const parser = Parser.instance;