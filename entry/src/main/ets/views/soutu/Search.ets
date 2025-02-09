import { collections } from '@kit.ArkTS';
import { Chip, ChipSize, LengthMetrics } from '@kit.ArkUI';
import { Const, UDataSource } from '../../common';
import { SourceResultList, TitleBar, TitleBarMenuItem } from '../../component';
import { site } from '../../helpers';
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
  /** 是否是以图搜图 */
  @State
  isCamera: boolean = false;
  /** 是否是页面初始化 */
  @State
  isInit: boolean = true;
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
  /** 搜索历史 */
  private histories: string[] = [];
  //
  private chipSize: Resource = $r('app.float.text_xs');
  private flexSpace = LengthMetrics.vp(6);

  aboutToAppear(): void {
    const value = site.pf.getSync(Const.searchHistory, new collections.Array<string>()) as collections.Array<string>;
    try {
      this.histories.push(...value);
    } catch (e) { }
  }

  /**
   * 返回值为 true 时，表示重写返回键逻辑，返回值为 false 时，表示回退到上一个页面
   * @returns
   */
  onBackPress(): boolean {
    return !this.isInit;
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
      if (this.isInit) {
        Column() {
          Row() {
            Text($r("app.string.search_history"))
              .fontSize(this.chipSize)
              .fontColor($r('sys.color.ohos_id_color_button_divider'))
            Button($r("app.string.clear"), { buttonStyle: ButtonStyleMode.TEXTUAL })
              .fontSize(this.chipSize)
              .fontColor($r('sys.color.ohos_id_color_button_divider'))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row, space: { main: this.flexSpace, cross: this.flexSpace } }) {
              ForEach(this.histories, (item: string, index: number) => {
                Chip({
                  label: { text: item, fontSize: this.chipSize },
                  size: ChipSize.SMALL,
                  onClose: () => this.historySplice(index, 1)
                })
              })
            }
            .constraintSize({ minHeight: '100%' })
          }
          .flex()
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .flex()
        .padding(10)
      } else {
        SourceResultList({ dataSource: this.dataSource })
          .width('100%')
          .flexGrow(1)
          .flexShrink(1)
          .flexBasis('0%')
          .margin({ top: 10 })
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => this.onBackPress())
  }

  @Builder
  buildSearchBar() {
    Search({ placeholder: $r("app.string.search_placeholder"), controller: this.controller })
      .textFont({ size: $r('app.float.text_xs') })
      .searchButton('>', { fontColor: $r('app.color.accent') })
      .onSubmit((value: string) => {
        this.searchPicture(value)
      })
  }

  @Styles
  flex() {
    .flexGrow(1)
    .flexShrink(1)
    .flexBasis('0%')
  }

  /** 历史记录删除和添加 */
  historySplice(start: number, deleteCount?: number, ...items: string[]): void {
    this.histories.splice(start, 1, ...items);
    site.pf.put(Const.searchHistory, collections.Array.from(this.histories));
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