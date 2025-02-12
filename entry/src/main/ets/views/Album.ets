import { TitleBar } from '../component';
import { site } from '../helpers';

@Builder
export function buildAlbum() {
  VAlbum()
}

@Component({ freezeWhenInactive: true })
export struct VAlbum {
  /**
   * 导航栈
   */
  @Consume('pageStack')
  pageStack: NavPathStack;
  @State
  message: string = 'Hello Album';
  /** 页面是否正在进入 */
  @State
  private _pageEnter: boolean = true;
  private _navDestinationId?: string;


  build() {
    NavDestination() {
      TitleBar({ title: $r('app.string.album') })

      RelativeContainer() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
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