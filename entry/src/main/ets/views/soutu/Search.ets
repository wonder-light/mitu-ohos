import { UDataSource } from '../../common';
import { SourceResultList, TitleBar, TitleBarMenuItem } from '../../component';
import { PictureSource } from '../../models';
import { SearchResultItem } from '../../models/Result';

@Builder
export function buildSearch() {
  VSearch();
}

@Component({ freezeWhenInactive: true })
export struct VSearch {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 数据源集合 TODO: 从存储中加载 */
  sources: PictureSource[] = [];
  /** 搜索控制器 */
  private controller: SearchController = new SearchController();
  /** 菜单 */
  private navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.camera"),
      action: (): void => { this.lookForPictures() }
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
  /** 数据懒加载源 */
  private dataSource: UDataSource<SearchResultItem> = new UDataSource<SearchResultItem>();

  aboutToAppear(): void {
    let isSearch = true;
    if (isSearch) {
      this.searchPicture('');
    } else {
      this.lookForPictures()
    }
  }

  build() {
    NavDestination() {
      TitleBar({
        enableBack: true,
        title: $r("app.string.soutu"),
        menuItems: this.navMenus,
        maxMenuCount: 1,
        customTitle: () => { this.buildSearchBar() }
      })
      SourceResultList({ dataSource: this.dataSource })
        .width('100%')
        .height('100%')
        .margin({ top: 10 })
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
  async searchPicture(value: string) {
    // TODO: 搜索图片
    this.generateData();
  }

  /** 以图搜图 */
  async lookForPictures() {
    // TODO: 以图搜图
    this.generateData();
  }

  /**
   * 生成的数据
   * @param callback 添加数据的回调
   * @param rule 发现项规则
   */
  generateData(): void {
    let fill = new SearchResultItem({
      thumbnail: 'https://images4.alphacoders.com/133/thumb-440-1335428.webp',
      origin: 'https://images4.alphacoders.com/133/thumb-1920-1335428.png'
    });
    let items = Array<SearchResultItem>(20).fill(fill);
    this.dataSource.pushAll(items);
  }
}