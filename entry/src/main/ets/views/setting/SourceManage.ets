import { TitleBar } from '../../component';

@Builder
export function buildSourceManage() {
  VSourceManage();
}

/** 图源管理 */
@Component
export struct VSourceManage {
  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.source_manage") })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}