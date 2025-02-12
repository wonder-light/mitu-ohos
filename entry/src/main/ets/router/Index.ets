import { Const } from '../common';
import { buildAlbum } from '../views/Album';
import { buildRepo } from '../views/Repo';
import { buildSetting } from '../views/Setting';
import { buildSoutu } from '../views/Soutu';
import { buildSearch } from '../views/soutu/Search';

// 路由
export const router: Record<string, WrappedBuilder<Object[]>> = {};
router[Const.soutu] = new WrappedBuilder(buildSoutu);
router[Const.album] = new WrappedBuilder(buildAlbum);
router[Const.repo] = new WrappedBuilder(buildRepo);
router[Const.setting] = new WrappedBuilder(buildSetting);
router[Const.search] = new WrappedBuilder(buildSearch);

/**
 * 构建路由
 *
 * WrappedBuilder
 */
@Builder
export function RouterBuild(name: string, param?: Object) {
  if (name != Const.notFound) {
    router[name].builder(param)
  } else {
    router[Const.notFound].builder(param)
  }
}