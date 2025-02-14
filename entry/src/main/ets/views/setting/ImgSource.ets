import { TitleBar } from '../../component';

@Builder
export function buildImgSourceManage() {
  VImgSourceManage();
}

/** 图源管理 */
@Component
export struct VImgSourceManage {
  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.img_source_manage") })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
  }
}