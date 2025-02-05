import { IDiscoverItemRule } from '../common';
import { SourceResultList, TitleBar, TitleBarMenuItem } from '../component';
import { DiscoverItemRule, PictureSource } from '../models';
import { Router } from '../router/Index';

@Builder
export function buildSoutu() {
  VSoutu();
}

@Component({ freezeWhenInactive: true })
export struct VSoutu {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 导航菜单 */
  navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.search"),
      action: (): void => this.pageStack.pushPathByName(Router.search, null, true)
    },
    {
      value: $r('app.media.camera'),
      action: (): void => { }
    }
  ];
  // 数据源 TODO: 从存储中加载
  sources: PictureSource = new PictureSource();
  /** Tabs 控制器 */
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    this.sources.discoverRule.urlRules.push(...[
      new DiscoverItemRule({ name: '必应' }),
      new DiscoverItemRule({ name: '百度' }),
      new DiscoverItemRule({ name: 'Pixiv' })
    ]);
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu"), menuItems: this.navMenus })
      if (this.sources!.discoverRule.urlRules.length <= 0) {
        Column() {
          Text($r('app.string.no_set_rule'))
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
          ForEach(this.sources.discoverRule.urlRules, (rule: IDiscoverItemRule, index: number) => {
            TabContent() {
              SourceResultList({ item: rule, discoverRule: this.sources.discoverRule })
                .width('100%')
                .height('100%')
            }
            .tabBar(rule.name)
          })
        }
        .scrollable(true)
        .barHeight(40)
        .barMode(BarMode.Scrollable, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT })
        .animationDuration(300)
        .fadingEdge(true)
        .height(`calc(100% - ${TitleBar.totalHeight}vp)`)
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}