import { HomeBuilder } from '../pages/Home';

/**
 * 路由
 */
export class Router {
  /**
   * 首页
   */
  static home: string = 'home';
  /**
   * 404 页面
   */
  static notFound: string = 'notFound';
}

// 路由
const router: Record<string, WrappedBuilder<object[]>> = {};
router[Router.home] = new WrappedBuilder(HomeBuilder);

/**
 * 构建路由
 *
 * WrappedBuilder
 */
@Builder
export function RouterBuild(name: string) {
  if (router[name] != null) {
    router[name].builder()
  } else {
    router[Router.notFound].builder()
  }
}