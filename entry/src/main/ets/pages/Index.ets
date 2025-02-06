import { Router, RouterBuild } from '../router/Index';
import { VSoutu } from '../views/Soutu';
import { ItemState, ToolBar, ToolBarOption, ToolBarOptions } from '@ohos.arkui.advanced.ToolBar';
import { VAlbum } from '../views/Album';
import { VRepo } from '../views/Repo';
import { VSetting } from '../views/Setting';
import { deviceInfo } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  /** 导航栈 */
  @Provide('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  /** 激活的页面索引 */
  @State
  activeIndex: number = 0;
  /** 工具栏 */
  @State
  toolbarItems: ToolBarOptions = new ToolBarOptions();
  /** 过渡效果 */
  effect: TransitionEffect = TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.Ease });
  /** 是大屏 */
  isLarge: boolean = true;
  /** 前面 Icon 的前景色 */
  private leadingIconColor: ResourceColor = $r('sys.color.icon_on');
  private leadingIconBg: ResourceColor = Color.Orange;
  private iconSize: Length = $r('app.float.icon_size');
  private iconSizeLg: Length = $r('app.float.icon_size_lg');
  private fontColor: ResourceColor = $r('sys.color.font');
  private arrow: ResourceStr = $r("app.media.arrow_right");
  private arrowColor: ResourceColor = $r('sys.color.ohos_id_color_button_divider');
  private activeColor: ResourceColor = $r('app.color.button_active');
  private bgColor: ResourceColor = $r('sys.color.ohos_id_color_background');
  private bgNormal: ResourceColor = $r('sys.color.ohos_id_color_button_normal');

  aboutToAppear(): void {
    // 是否是手机
    if (deviceInfo.deviceType == 'phone') {
      this.isLarge = false;
    }
    const names = [Router.soutu, Router.album, Router.repo, Router.setting];
    const items: ToolBarOption[] = [
      { content: $r("app.string.soutu"), icon: $r("app.media.soutu") },
      { content: $r('app.string.album'), icon: $r('app.media.album') },
      { content: $r('app.string.repo'), icon: $r('app.media.repo') },
      { content: $r('app.string.setting'), icon: $r('app.media.setting') }
    ];
    items.forEach((item, index) => {
      item.state = ItemState.ACTIVATE;
      if (this.isLarge) {
        item.action = (): void => this.toRouter(names[index], index);
      } else {
        item.action = () => this.activeIndex = index;
      }
      this.toolbarItems.push(item);
    });
  }

  build() {
    Navigation(this.pageStack) {
      if (!this.isLarge) {
        if (this.activeIndex == 0) {
          VSoutu().transition(this.effect)
        } else if (this.activeIndex == 1) {
          VAlbum().transition(this.effect)
        } else if (this.activeIndex == 2) {
          VRepo().transition(this.effect)
        } else {
          VSetting().transition(this.effect)
        }
      } else {
        this.buildPanel()
      }
    }
    .onAppear(() => this.navAppear())
    .mode(NavigationMode.Auto)
    .navDestination(RouterBuild)
    .toolbarConfiguration(this.buildToolbar)
    .title('Soutu')
    .titleMode(NavigationTitleMode.Mini)
    .hideToolBar(this.isLarge)
    .hideTitleBar(!this.isLarge)
    .hideBackButton(true)
  }

  @Builder
  buildPanel() {
    List({ space: 4, initialIndex: this.activeIndex }) {
      ListItemGroup({ space: 4, style: ListItemGroupStyle.CARD }) {
        ForEach(this.toolbarItems, (item: ToolBarOption, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal, buttonStyle: ButtonStyleMode.TEXTUAL }) {
              Row() {
                Image(item.icon)
                  .borderRadius(999)
                  .backgroundColor(this.leadingIconBg)
                  .fillColor(this.leadingIconColor)
                  .width(this.iconSizeLg)
                  .height(this.iconSizeLg)
                  .padding(4)
                Text(item.content)
                  .flexGrow(1)
                  .margin({ left: 8, right: 8 })
                  .fontColor(this.fontColor)
                Image(this.arrow)
                  .width(this.iconSize)
                  .height(this.iconSize)
                  .fillColor(this.arrowColor)
              }
              .width('100%')
            }
            .padding(12)
            .borderRadius(12)
            .width('100%')
            .onClick(item.action)
            .backgroundColor(this.activeIndex == index ? this.activeColor : this.bgColor)
          }
        })
      }
      .divider({
        strokeWidth: 1,
        color: this.bgNormal,
        startMargin: this.iconSize,
        endMargin: this.iconSize
      })
      .borderWidth(0.5)
      .borderColor(this.bgNormal)
      .shadow({ color: this.bgNormal, radius: 12 })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  @Builder
  buildToolbar() {
    ToolBar({
      activateIndex: this.activeIndex, toolBarList: this.toolbarItems
    })
  }

  /** 导航栏显示 */
  navAppear() {
    if (this.isLarge) {
      this.pageStack.pushPathByName(Router.soutu, null, true);
    }
  }

  /** 跳转路由 */
  toRouter(name: string, index: number) {
    let isCurrent = this.pageStack.getAllPathName().pop() == name;
    if (this.activeIndex == index && isCurrent) {
      return;
    }
    this.activeIndex = index;
    this.pageStack.pushPathByName(name, null, true);
  }
}