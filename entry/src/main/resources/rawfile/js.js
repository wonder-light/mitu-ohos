class EtsBridge {
  exeEval(str) {
    return eval(str)
  }
}


// 注册同步函数
dsBridge.register('js', new EtsBridge())