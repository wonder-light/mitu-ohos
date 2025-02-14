import { TitleBar } from '../component';
import { site } from '../helpers';

@Builder
export function buildAlbum() {
  VAlbum()
}

@Component({ freezeWhenInactive: true })
export struct VAlbum {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 是大屏 */
  @Consume('isLarge')
  isLarge: boolean;
  @State
  message: string = 'Hello Album';
  /** 页面是否正在进入, 大屏为 true, 小屏则为 false */
  @State
  private _pageEnter: boolean = true;
  private _navDestinationId?: string;

  aboutToAppear(): void {
    this._pageEnter = this.isLarge;
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r('app.string.album') })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .opacity(this._pageEnter ? 0 : 1)
    .onDisAppear(() => site.unregisterNavTransition(this._navDestinationId!))
    .onReady((ctx) => {
      site.registerNavTransition(this._navDestinationId = ctx.navDestinationId!, {
        onInit: (isExit) => this._pageEnter = !isExit,
        onEnd: (isExit) => this._pageEnter = isExit
      });
    })
  }
}