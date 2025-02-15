import { Const } from '../../common';
import { TitleBar } from '../../component';

@Builder
export function buildBedSourceManage() {
  VBedSourceManage();
}

/** 图源管理 */
@Component
export struct VBedSourceManage {
  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.bed_source_manage") })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor(Const.cBackground)
  }
}