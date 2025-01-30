import { PictureSource, SourceItem } from 'picture_search';
import { TitleBar, TitleBarMenuItem } from '../component/common/TitleBar';
import { SourceResultList } from '../component/search/SourceList';


@Builder
export function buildSearch() {
  VSearch();
}

@Component({ freezeWhenInactive: true })
export struct VSearch {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 导航菜单 */
  navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.search"),
      action: (): void => { }
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
    this.sources.sourceList.push(...[
      new SourceItem(),
      new SourceItem(),
      new SourceItem()
    ]);
    // TODO: JSVM-API 动态加载JS代码
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu"), menuItems: this.navMenus })
      if (this.sources.sourceList.length <= 0) {
        Column() {
          Text($r('app.string.no_set_rule'))
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
          ForEach(this.sources.sourceList, (source: SourceItem, index: number) => {
            TabContent() {
              SourceResultList({source: source})
                .width('100%')
                .height('100%')
            }
            .tabBar(source.name + 'TTT')
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