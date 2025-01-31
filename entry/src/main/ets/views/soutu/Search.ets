import { TitleBar, TitleBarMenuItem } from '../../component/common/TitleBar';

@Builder
export function buildSearch() {
  VSearch();
}

@Component({ freezeWhenInactive: true })
export struct VSearch {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 搜索控制器 */
  private controller: SearchController = new SearchController();
  /** 菜单 */
  private navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.camera"),
      action: (): void => this.lookForPictures()
    },
    {
      label: $r("app.string.source_manage"),
      action: (): void => { }
    },
    {
      label: $r("app.string.multi_group"),
      action: (): void => { }
    }
  ];

  build() {
    NavDestination() {
      TitleBar({
        enableBack: true,
        title: $r("app.string.soutu"),
        menuItems: this.navMenus,
        maxMenuCount: 1,
        customTitle: () => { this.buildSearchBar() }
      })

      Text('dkfjskejflkds')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  buildSearchBar() {
    Search({ placeholder: $r("app.string.search_placeholder"), controller: this.controller })
      .searchButton('>')
      .onSubmit((value: string) => {
        this.searchPicture(value)
      })
  }

  /** 搜索 changeValue 对应的图片 */
  searchPicture(value: string): void {

  }

  /** 以图搜图 */
  lookForPictures(): void {

  }
}