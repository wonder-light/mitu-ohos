
/**
 * 路由
 */
export class Router {
  /**
   * 404 页面
   */
  static notFound: string = 'notFound';
}

// 路由
const router: Record<string, WrappedBuilder<object[]>> = {};

/**
 * 构建路由
 *
 * WrappedBuilder
 */
@Builder
export function RouterBuild(name: string, param: object) {
  if (router[name] != null) {
    router[name].builder()
  } else {
    router[Router.notFound].builder()
  }
}