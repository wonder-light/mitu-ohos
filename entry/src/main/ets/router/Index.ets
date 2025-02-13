import { Const } from '../common';
import { buildAlbum } from '../views/Album';
import { buildSetting } from '../views/Setting';
import { buildSourceManage } from '../views/setting/SourceManage';
import { buildSoutu } from '../views/Soutu';
import { buildSearch } from '../views/soutu/Search';

// 路由
export const router: Record<string, WrappedBuilder<Object[]>> = {};
router[Const.soutu] = new WrappedBuilder(buildSoutu);
router[Const.album] = new WrappedBuilder(buildAlbum);
router[Const.setting] = new WrappedBuilder(buildSetting);
router[Const.search] = new WrappedBuilder(buildSearch);
router[Const.sourceManage] = new WrappedBuilder(buildSourceManage);

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