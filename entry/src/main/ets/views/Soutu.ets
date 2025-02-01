import { DiscoverItemRule, IDiscoverItemRule, PictureSource } from 'picture_search';
import { TitleBar, TitleBarMenuItem } from '../component/common/TitleBar';
import { SourceResultList } from '../component/search/SourceList';
import Log from '../helpers/Log';
import { Router } from '../router/Index';
import hello from 'eval_js'


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
  sources: PictureSource = new PictureSource();
  /** Tabs 控制器 */
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    this.sources.discoverRule.urlRules.push(...[
      new DiscoverItemRule(),
      new DiscoverItemRule(),
      new DiscoverItemRule()
    ]);
    // TODO: JSVM-API 动态加载JS代码
    Log.i('----------------------------------')
    Log.i(typeof hello)
    Log.i('----------------------------------')
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu"), menuItems: this.navMenus })
      if (this.sources.discoverRule.urlRules.length <= 0) {
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
            .tabBar(rule.name + 'TTT')
          })
        }
        .scrollable(true)
        .barHeight(40)
        .barMode(BarMode.Scrollable, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT })
        .animationDuration(300)
        .fadingEdge(true)
        .onChange((index: number) => {
          console.info(index.toString())
        })
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}