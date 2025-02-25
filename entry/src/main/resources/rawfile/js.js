/**
 * ETS 中的函数
 */
class EtsBridge {
  /**
   * ets.info
   * @param {string[]} args
   */
  info(...args) {
    dsBridge.call('ets.info', args)
  }

  /**
   * ets.warn
   * @param {string[]} args
   */
  warn(...args) {
    dsBridge.call('ets.warn', args)
  }

  /**
   * ets.warn
   * @param {string[]} args
   */
  error(...args) {
    dsBridge.call('ets.error', args)
  }
}

/**
 * 获取错误对象
 * @param {Error} e
 * @returns
 */
function _getError(e) {
  return { message: e.message, stack: e.stack, error: true }
}

/**
 * 将字符串解析为 DOM 对象
 * @param {string} html
 * @returns {Document}
 */
function domParse(html) {
  let parser = new DOMParser();
  return parser.parseFromString(html, 'application/xhtml+xml')
}

/**
 * 注册可以在 ETS 中调用的函数, 同步函数
 */
class JsBridge {

}

/**
 * 注册可以在 ETS 中调用的函数, 异步函数
 */
class JsBridgeAsync {
  /**
   * 执行 eval 函数
   * @param {string} code 代码
   * @param {(...arg) => void} callback 结果回调
   */
  async exeEval(code, callback) {
    try {
      let value = eval(code);
      if (value instanceof Promise) {
        value = await value;
      }
      callback(value)
    } catch (e) {
      callback(_getError(e))
    }
  }

  /**
   * 添加库
   * @param {string[]} libs 脚本库集合
   * @param {(...arg) => void} callback 结果回调
   * @see https://www.cnblogs.com/kunmomo/p/12153492.html
   */
  async addLibs(libs, callback) {
    try {
      $LAB.setOptions({ AlwaysPreserveOrder: true })
        .script(...libs)
        .wait(() => callback(true))
    } catch (e) {
      callback(_getError(e))
    }
  }

  /**
   * 执行 JsonPath 查询
   * @param json json 字符串
   * @param path JsonPath 字符串
   * @param callback
   */
  async jsonPath(json, path, callback) {
    try {
      let value = JSONPath({ path, json });
      callback(value)
    } catch (e) {
      callback(_getError(e))
    }
  }

  /**
   * 执行 xpath 查询
   * @param html html 字符串
   * @param path xpath 字符串
   * @param isHtml 是否需要返回 html 字符串
   * @param callback
   */
  async htmlPath(html, path, isHtml, callback) {
    let dom;
    try {
      dom = domParse(html);
    } catch (e) {
      callback(_getError(e))
    }
    let error = null;
    // xpath
    try {
      let values = [];
      let nodes = dom.evaluate(path, dom, null, XPathResult.ANY_TYPE, null);
      let node = null;
      while ((node = nodes.iterateNext()) != null) {
        values.push(isHtml == true ? (node.outerHTML ?? node.textContent) : node.textContent)
      }
      callback(values);
      return;
    } catch (e) {
      error = e
    }
    // css query
    try {
      let values = [];
      let nodes = dom.querySelectorAll(path);
      for (let i = 0; i < nodes.length; i++) {
        let node = nodes[i];
        values.push(isHtml == true ? (node.outerHTML ?? node.textContent) : node.textContent)
      }
      callback(values);
    } catch (e) {
      e.message = error.message + '\n\n' + e.message;
      e.stack = error.stack + '\n\n' + e.stack;
      callback(_getError(e))
    }
  }
}


// 注册可以在 ETS 中调用的函数, 同步函数
dsBridge.register('js', new JsBridge())
// 注册可以在 ETS 中调用的函数, 异步函数
dsBridge.registerAsyn('js', new JsBridgeAsync())
// 注册 ETS 中调用的函数
window.ets = new EtsBridge()