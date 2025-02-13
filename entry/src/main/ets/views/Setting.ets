import { TitleBar } from '../component';
import { site } from '../helpers';

@Builder
export function buildSetting() {
  VSetting()
}

@Component({ freezeWhenInactive: true })
export struct VSetting {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 是大屏 */
  @Consume('isLarge')
  isLarge: boolean;
  @State
  message: string = 'Hello Setting';
  /** 页面是否正在进入, 大屏为 true, 小屏则为 false */
  @State
  private _pageEnter: boolean = true;
  private _navDestinationId?: string;

  aboutToAppear(): void {
    this._pageEnter = this.isLarge;
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu") })

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