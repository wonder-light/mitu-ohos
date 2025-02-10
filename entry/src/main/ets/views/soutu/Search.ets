import { collections } from '@kit.ArkTS';
import { Chip, ChipSize, LengthMetrics } from '@kit.ArkUI';
import { Const, UDataSource } from '../../common';
import { Loading, SourceResultList, TitleBar, TitleBarMenuItem } from '../../component';
import { site } from '../../helpers';
import { PictureSource } from '../../models';
import { SearchResultItem } from '../../models/Result';
import { MediaUt } from '../../utils';

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
  /** 是否显示搜搜历史页面 */
  @State
  isShow: boolean = true;
  /** 是否正在加载 */
  @State
  isLoading: boolean = false;
  /** 数据源集合 TODO: 从存储中加载 */
  sources: PictureSource[] = [];
  /** 搜索文本值 */
  @State
  private searchValue: string = '';
  /** 搜索控制器 */
  private controller: SearchController = new SearchController();
  /** 菜单 */
  private navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.camera"),
      action: (): Promise<void> => this.lookForPictures()
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
  /** 清除历史 */
  @State
  private clearHistory: boolean = false;
  //
  private chipSize: Resource = $r('app.float.text_xs');
  private flexSpace = LengthMetrics.vp(6);
  private animateParam: AnimateParam = { duration: 200, curve: Curve.Ease };

  aboutToAppear(): void {
    const value = site.pf.getSync(Const.searchHistory, new collections.Array<string>()) as collections.Array<string>;
    this.histories.push(...value);
  }

  aboutToDisappear(): void {
    site.pf.putSync(Const.searchHistory, collections.Array.from(this.histories));
  }

  /**
   * 返回值为 true 时，表示重写返回键逻辑，返回值为 false 时，表示回退到上一个页面
   * @returns
   */
  onBackPress(): boolean {
    if (this.isShow) return false;
    animateTo(this.animateParam, () => this.isShow = true);
    return true;
  }

  build() {
    NavDestination() {
      TitleBar({
        enableBack: true,
        title: $r("app.string.soutu"),
        menuItems: this.navMenus,
        maxMenuCount: 1,
        customTitle: () => { this.buildSearchBar() },
        backCall: () => (this.onBackPress() ? null : this.pageStack.pop())
      })
      Column() {
        if (this.isShow) {
          Row() {
            Text($r("app.string.search_history"))
              .fontSize(this.chipSize)
              .fontColor($r('app.color.button_divider'))
            Button($r("app.string.clear"), { buttonStyle: ButtonStyleMode.TEXTUAL, controlSize: ControlSize.SMALL })
              .fontSize(this.chipSize)
              .fontColor($r('app.color.button_divider'))
              .onClick(() => {
                this.histories.splice(0, this.histories.length);
                this.clearHistory = !this.clearHistory;
              })
          }
          .width('100%')
          .padding({ left: 8, right: 8 })
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row, space: { main: this.flexSpace, cross: this.flexSpace } }) {
              Repeat(this.clearHistory ? this.histories : this.histories).each((item) => {
                Chip({
                  label: { text: item.item, fontSize: this.chipSize },
                  size: ChipSize.SMALL,
                  onClose: () => this.histories.splice(item.index, 1),
                  onClicked: () => this.searchPicture(item.item)
                })
              })
            }
          }
          .flex()
          .padding(8)
          .scrollBar(BarState.Off)
          .align(Alignment.TopStart)
        } else if (this.isLoading) {
          Column() {
            Loading()
          }
          .justifyContent(FlexAlign.Center)
        } else {
          SourceResultList({ dataSource: this.dataSource })
            .width('100%')
            .height('100%')
            .margin({ top: 10 })
        }
      }
      .width('100%')
      .flex()
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => this.onBackPress())
  }

  @Builder
  buildSearchBar() {
    Search({ placeholder: $r("app.string.search_placeholder"), value: $$this.searchValue, controller: this.controller })
      .textFont({ size: $r('app.float.text_xs') })
      .searchButton('>', { fontColor: $r('app.color.accent') })
      .onSubmit((value: string) => this.searchPicture(value))
  }

  @Styles
  flex() {
    .flexGrow(1)
    .flexShrink(1)
    .flexBasis('0%')
  }

  /** 搜索 changeValue 对应的图片 */
  async searchPicture(value: string) {
    // 无效值
    if (value.trim().length <= 0) return;
    // 设置显示的值
    this.searchValue = value;
    // 停止编辑
    this.controller.stopEditing();
    // 动画
    animateTo(this.animateParam, () => this.isLoading = !(this.isShow = false))
    // 添加历史
    let index = this.histories.indexOf(value);
    // 把已有的历史放到最前面
    if (index >= 0) this.histories.splice(index, 1);
    this.histories.unshift(value);
    // 以图搜图
    if (value.startsWith('file://') || value.startsWith('http')) {
      // TODO: 搜索图片
      this.generateData();
    } else {
      // TODO: 搜索图片
      this.generateData();
    }
    // 动画
    animateTo(this.animateParam, () => this.isLoading = false);
  }

  /** 以图搜图 */
  async lookForPictures() {
    //await MediaUt.selectFile({ fileSuffixFilters:  ['jpg', 'jpeg', 'png', 'gif'] });
    // 拉起图片选择器
    const fileUrl = await MediaUt.selectPicture();
    if (fileUrl) {
      this.searchValue = fileUrl;
    }
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