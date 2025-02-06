/**
 * 规则解析器
 */
export class Parser {
  /** 单例 */
  static readonly instance: Parser = new Parser();

  // 私有化构造器
  private constructor() { }
}

/**
 * 规则解析器单例
 */
export const parser = Parser.instance;