import { common } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { DEBUG } from 'BuildProfile';
import { Const } from '../common';
import { IListGroupItem, ListGroup, TitleBarMenuItem } from '../component';
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
  toolbarItems: IListGroupItem[] = [
    { label: $r("app.string.soutu"), value: $r("app.media.soutu"), suffix: Const.mArrowRight },
    { label: $r('app.string.album'), value: $r('app.media.album'), suffix: Const.mArrowRight },
    { label: $r('app.string.setting'), value: $r('app.media.setting'), suffix: Const.mArrowRight }
  ];
  /** Tabs 控制器 */
  tabsController: TabsController = new TabsController();
  /** 路由名称 */
  private readonly _routeNames: string[] = [Const.soutu, Const.album, Const.setting];

  aboutToAppear(): void {
    this.tabsController.changeIndex(this.activeIndex);
    if (this.isLarge) {
      this.toolbarItems.forEach((item: TitleBarMenuItem, index: number) => {
        item.action = (): void => this.toRouter(this._routeNames[index], index)
      });
    }
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
            .safeArea()
          })
        }
        .safeArea()
        .divider(null)
        .scrollable(false)
        .barBackgroundColor(Const.cAccent)
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
    .backgroundColor(Const.cBackground)
    .customNavContentTransition((from, to, option) => this.navTransition(from, to, option))
  }

  @Builder
  buildPanel() {
    ListGroup({
      groups: [{ items: this.toolbarItems }],
      initialIndex: this.activeIndex,
      accentPrefix: true,
      dividerWidth: 1,
      dividerMargin: Const.fIconSize,
      selectIndex: this.activeIndex
    })
  }

  /** 扩大安全区域 */
  @Styles
  safeArea() {
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  /** 导航切换动画 */
  navTransition(from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation): NavigationAnimatedTransition | undefined {
    // 首页不进行自定义动画
    if (from.index === -1 || to.index === -1) {
      return undefined;
    }
    const fromTran = site.getNavTransition(from.navDestinationId);
    const toTran = site.getNavTransition(to.navDestinationId);
    const finish = () => {
      fromTran?.onEnd(true);
      toTran?.onEnd(false);
    };
    fromTran?.onInit(true)
    toTran?.onInit(false)
    // 有一个无效时使用默认动画
    if (!toTran || !fromTran) {
      animateTo(Const.animate, finish)
      return undefined;
    }
    return {
      transition: (proxy) => {
        animateTo({ duration: Const.animate.duration, curve: Const.animate.curve, onFinish: () => proxy.finishTransition() }, finish);
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
      .iconStyle({ selectedColor: Const.cPrimary, unselectedColor: Const.cFont })
      .labelStyle({ selectedColor: Const.cPrimary, unselectedColor: Const.cFont })
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