import { buildAlbum } from '../views/Album';
import { buildRepo } from '../views/Repo';
import { buildSoutu } from '../views/Soutu';
import { buildSetting } from '../views/Setting';

/**
 * 路由
 */
export class Router {
  /** 搜索页面 */
  static readonly search: string = 'search';
  /** 相册页面 */
  static readonly album: string = 'album';
  /** 仓库页面 */
  static readonly repo: string = 'repo';
  /** 设置页面 */
  static readonly setting: string = 'setting';
  /** 404 页面 */
  static readonly notFound: string = 'notFound';
}


// 路由
const router: Record<string, WrappedBuilder<object[]>> = {};
router[Router.search] = new WrappedBuilder(buildSoutu);
router[Router.album] = new WrappedBuilder(buildAlbum);
router[Router.repo] = new WrappedBuilder(buildRepo);
router[Router.setting] = new WrappedBuilder(buildSetting);

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