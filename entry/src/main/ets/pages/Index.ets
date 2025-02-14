import { common } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DEBUG } from 'BuildProfile';
import { Const } from '../common';
import { TitleBarMenuItem } from '../component';
import { site } from '../helpers';
import { RouterBuild } from '../router/Index';

@Entry
@Component
struct Index {
  /** 导航栈 */
  @Provide('pageStack')
  pageStack: NavPathStack = new NavPathStack();
  /** 是大屏 */
  @Provide('isLarge')
  isLarge: boolean = deviceInfo.deviceType !== 'phone';
  /** 激活的页面索引 */
  @State
  activeIndex: number = 0;
  /** 工具栏 */
  @State
  toolbarItems: TitleBarMenuItem[] = [
    { label: $r("app.string.soutu"), value: $r("app.media.soutu") },
    { label: $r('app.string.album'), value: $r('app.media.album') },
    { label: $r('app.string.setting'), value: $r('app.media.setting') }
  ];
  /** Tabs 控制器 */
  tabsController: TabsController = new TabsController();
  /** 路由名称 */
  private readonly _routeNames: string[] = [Const.soutu, Const.album, Const.setting];
  /** 前面 Icon 的前景色 */
  private _iconOn: ResourceColor = $r('app.color.icon_on');
  private _accent: ResourceColor = $r('app.color.accent');
  private _iconSize: Length = $r('app.float.icon_size');
  private _iconSizeLg: Length = $r('app.float.icon_size_lg');
  private _fontColor: ResourceColor = $r('app.color.font');
  private _arrow: ResourceStr = $r("sys.media.ohos_ic_public_arrow_right");
  private _divider: ResourceColor = $r("app.color.button_divider");
  private _activeColor: ResourceColor = $r('app.color.button_active');
  private _background: ResourceColor = $r('app.color.background');
  private _buttonNormal: ResourceColor = $r('app.color.button_normal');

  aboutToAppear(): void {
    this.tabsController.changeIndex(this.activeIndex);
    if (DEBUG) {
      import('@hadss/debug-db').then(async (ns) => {
        await ns.DebugDB.initialize(getContext(this) as common.UIAbilityContext);
      });
    }
  }

  onPageHide(): void {
    site.pf.flushSync();
  }

  build() {
    Navigation(this.pageStack) {
      if (this.isLarge) {
        this.buildPanel()
      } else {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
          ForEach(this.toolbarItems, (item: TitleBarMenuItem, index) => {
            TabContent() {
              RouterBuild(this._routeNames[index])
            }
            .opacity(this.activeIndex === index ? 1 : 0)
            .tabBar(this.getTabStyle(item))
          })
        }
        .divider(null)
        .scrollable(false)
        .animationDuration(Const.animate.duration)
        .customContentTransition((from, to) => this.tabTransition(from, to))
      }
    }
    .onAppear(() => this.navAppear())
    .mode(NavigationMode.Auto)
    .navDestination(RouterBuild)
    .title($r('app.string.app_name'))
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(!this.isLarge)
    .hideToolBar(true)
    .hideBackButton(true)
    .customNavContentTransition((from, to, option) => this.navTransition(from, to, option))
  }

  @Builder
  buildPanel() {
    List({ space: 4, initialIndex: this.activeIndex }) {
      ListItemGroup({ space: 4, style: ListItemGroupStyle.CARD }) {
        ForEach(this.toolbarItems, (item: TitleBarMenuItem, index) => {
          ListItem() {
            Button({ type: ButtonType.Normal, buttonStyle: ButtonStyleMode.TEXTUAL }) {
              Row() {
                Image(item.value)
                  .borderRadius(999)
                  .backgroundColor(this._accent)
                  .fillColor(this._iconOn)
                  .width(this._iconSizeLg)
                  .height(this._iconSizeLg)
                  .padding(4)
                Text(item.label)
                  .flexGrow(1)
                  .margin({ left: 8, right: 8 })
                  .fontColor(this._fontColor)
                Image(this._arrow)
                  .width(this._iconSize)
                  .height(this._iconSize)
                  .fillColor(this._divider)
              }
              .width('100%')
            }
            .padding(12)
            .borderRadius(12)
            .width('100%')
            .onClick(() => this.toRouter(this._routeNames[index], index))
            .backgroundColor(this.activeIndex == index ? this._activeColor : Color.Transparent)
          }
        })
      }
      .divider({
        strokeWidth: 1,
        color: this._buttonNormal,
        startMargin: this._iconSize,
        endMargin: this._iconSize
      })
      .borderWidth(0.5)
      .borderColor(this._buttonNormal)
      .shadow({ color: this._buttonNormal, radius: 12 })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  /** 导航切换动画 */
  navTransition(from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation): NavigationAnimatedTransition | undefined {
    // 首页不进行自定义动画
    if (from.index === -1 || to.index === -1) {
      return undefined;
    }
    const fromTran = site.getNavTransition(from.navDestinationId);
    const toTran = site.getNavTransition(to.navDestinationId);
    // 有一个无效时使用默认动画
    if (!toTran || !fromTran) {
      return undefined;
    }
    fromTran.onInit(true)
    toTran.onInit(false)
    return {
      transition: (proxy) => {
        animateTo({ duration: Const.animate.duration, curve: Const.animate.curve, onFinish: () => proxy.finishTransition() }, () => {
          fromTran.onEnd(true);
          toTran.onEnd(false);
        });
      }
    };
  }

  /** Tab 内容切换动画  */
  tabTransition(from: number, to: number): TabContentAnimatedTransition {
    return {
      transition: (proxy: TabContentTransitionProxy) => {
        animateTo({ duration: Const.animate.duration, curve: Const.animate.curve, onFinish: () => proxy.finishTransition() }, () => {
          this.activeIndex = to;
        });
      }
    };
  }

  /** 获取 TabBar 样式 */
  getTabStyle(item: TitleBarMenuItem) {
    return BottomTabBarStyle.of(item.value, item.label)
      .iconStyle({ selectedColor: this._accent, unselectedColor: this._fontColor })
      .labelStyle({ selectedColor: this._accent, unselectedColor: this._fontColor })
  }

  /** 导航栏显示 */
  navAppear() {
    if (this.isLarge) {
      this.pageStack.pushPathByName(Const.soutu, null, true);
    }
  }

  /** 跳转路由 */
  toRouter(name: string, index: number) {
    let isCurrent = this.pageStack.getAllPathName().pop() == name;
    if (this.activeIndex == index && isCurrent) {
      return;
    }
    animateTo(Const.animate, () => this.activeIndex = index)
    index = this.pageStack.moveToTop(name, true);
    if (index < 0) this.pageStack.pushPathByName(name, null, true);
  }
}