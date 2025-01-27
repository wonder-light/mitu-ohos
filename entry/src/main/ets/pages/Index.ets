import { RouterBuild } from '../router/Index';
import { VSearch } from './Search';
import { ItemState, ToolBar, ToolBarOptions } from '@ohos.arkui.advanced.ToolBar';
import { VAlbum } from './Album';
import { VRepo } from './Repo';
import { VSetting } from './Setting';

@Entry
@Component
struct Index {
  /**
   * 导航栈
   */
  @Provide('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  /**
   * 激活的页面索引
   */
  @State
  activeIndex: number = 0;
  /**
   * 工具栏
   */
  @State
  toolbarItems: ToolBarOptions = new ToolBarOptions();
  /**
   * 过渡效果
   */
  effect: TransitionEffect = TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Ease });

  aboutToAppear(): void {
    const names = ['search', 'album', 'repo', 'setting'];
    names.forEach((name, index) => {
      this.toolbarItems.push({
        content: $r(`app.string.${name}`),
        icon: $r(`app.media.${name}`),
        state: ItemState.ACTIVATE,
        action: () => this.activeIndex = index,
      });
    });
  }

  build() {
    Navigation(this.pageStack) {
      if (this.activeIndex == 0) {
        VSearch().transition(this.effect)
      } else if (this.activeIndex == 1) {
        VAlbum().transition(this.effect)
      } else if (this.activeIndex == 2) {
        VRepo().transition(this.effect)
      } else {
        VSetting().transition(this.effect)
      }
    }
    .navDestination(RouterBuild)
    .toolbarConfiguration(this.buildToolbar)
  }

  @Builder
  buildToolbar() {
    ToolBar({
      activateIndex: this.activeIndex,
      toolBarList: this.toolbarItems,
    })
  }
}