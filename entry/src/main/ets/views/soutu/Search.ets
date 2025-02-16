import { collections, HashMap } from '@kit.ArkTS';
import { Chip, ChipSize, LengthMetrics } from '@kit.ArkUI';
import { BaseDao } from '@ohos/dataorm';
import { Const, IPictureSource, UDataSource } from '../../common';
import { ISheetInfo, Loading, SelectDialog, SourceResultList, TitleBar, TitleBarMenuItem } from '../../component';
import { site } from '../../helpers';
import { PictureSource, SearchRule } from '../../models';
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
  sources: SearchRule[] = [];
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
      label: $r("app.string.img_source_manage"),
      action: (): void => this.pageStack.pushPathByName(Const.imgSourceManage, null, true)
    },
    {
      label: $r("app.string.multi_group"),
      action: (): Promise<void> => this.switchSource()
    }
  ];
  /** 数据懒加载源 */
  private dataSource: UDataSource<SearchResultItem> = new UDataSource<SearchResultItem>();
  /** 搜索历史 */
  private histories: collections.Array<string> = new collections.Array();
  /** 在清除历史后用于更新列表 */
  @State
  private clearHistory: boolean = false;
  /** 弹窗控制器 */
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: $r("app.string.switch_img_source"),
      options: [
        {
          name: $r('app.string.group'),
          contents: () => this.getSelectContents(0),
          selectedIndex: () => this.getSelectIndex(0),
          isRadio: false
        },
        {
          name: $r("app.string.img_source"),
          contents: () => this.getSelectContents(1),
          selectedIndex: () => this.getSelectIndex(1)
        }
      ],
      onConfirm: (index, items) => this.confirmSelects(index, items)
    }),
    cornerRadius: Const.fPadding4
  });
  /** 数据源 */
  declare private dao: BaseDao<PictureSource, number>;
  /** 分组选项: 分组 - id 数组 */
  private groupOptions: HashMap<string, number[]> = new HashMap();
  /** 源选项: value - id */
  private sourceOptions: ISheetInfo[] = [];
  /** 选择的索引选项: 值 - index */
  private indexOptions: HashMap<Object, number> = new HashMap();
  /** 选择的值 index - values*/
  private selectOptions: HashMap<number, Object[]> = new HashMap();
  /** 选择的规则分组或id */
  private selects: collections.Array<string | number> = new collections.Array();
  //
  private flexSpace = LengthMetrics.vp(6);

  aboutToAppear(): void {
    this.dao = site.db.getBaseDao<PictureSource, number>(PictureSource);
    this.histories = site.pf.getSync(Const.searchHistory, this.histories) as collections.Array<string>;
    this.selects = site.pf.getSync(Const.searchSelects, this.selects) as collections.Array<string | number>;
    // 设置选项的初始值
    let groups: Object[] = [];
    let sources: Object[] = [];
    for (const element of this.selects) {
      typeof element === 'string' ? groups.push(element) : sources.push(element);
    }
    this.selectOptions.set(0, groups)
    this.selectOptions.set(1, sources)
  }

  /**
   * 返回值为 true 时，表示重写返回键逻辑，返回值为 false 时，表示回退到上一个页面
   * @returns
   */
  onBackPress(): boolean {
    if (this.isShow) return false;
    animateTo(Const.animate, () => this.isShow = true);
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
              .fontSize(Const.fTextXs)
              .fontColor(Const.cButtonDivider)
            Button($r("app.string.clear"), { buttonStyle: ButtonStyleMode.TEXTUAL, controlSize: ControlSize.SMALL })
              .fontSize(Const.fTextXs)
              .fontColor(Const.cButtonDivider)
              .onClick(() => {
                this.histories.splice(0, this.histories.length);
                this.clearHistory = !this.clearHistory;
              })
          }
          .width('100%')
          .padding({ left: Const.fPadding2, right: Const.fPadding2 })
          .justifyContent(FlexAlign.SpaceBetween)

          Scroll() {
            Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row, space: { main: this.flexSpace, cross: this.flexSpace } }) {
              Repeat([...this.clearHistory ? this.histories : this.histories]).each((item) => {
                Chip({
                  label: { text: item.item, fontSize: Const.fTextXs },
                  size: ChipSize.SMALL,
                  onClose: () => this.histories.splice(item.index, 1),
                  onClicked: () => this.searchPicture(item.item)
                })
              })
            }
          }
          .flex()
          .padding(Const.fPadding2)
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
            .margin({ top: Const.fPadding3 })
        }
      }
      .width('100%')
      .flex()
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor(Const.cBackground)
    .onBackPressed(() => this.onBackPress())
  }

  @Builder
  buildSearchBar() {
    Search({ placeholder: $r("app.string.search_placeholder"), value: $$this.searchValue, controller: this.controller })
      .textFont({ size: Const.fTextXs })
      .searchButton('>', { fontColor: Const.cPrimary })
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
    animateTo(Const.animate, () => this.isLoading = !(this.isShow = false))
    // 更新历史
    this.updateHistory(value);
    // 以图搜图
    if (value.startsWith('file://') || value.startsWith('http')) {
      // TODO: 搜索图片
      this.generateData();
    } else {
      // TODO: 搜索图片
      this.generateData();
    }
    // 动画
    animateTo(Const.animate, () => this.isLoading = false);
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

  /** 选择图片源 */
  async switchSource() {
    // 获取数据源
    let results = await this.dao.queryBuilder().select('id', 'name', 'groups').listSqlAs<IPictureSource>();
    this.indexOptions.clear();
    this.groupOptions.clear();
    this.sourceOptions = [];
    let index = 0;
    for (let item of results) {
      this.sourceOptions.push({ title: item.name!, value: item.id! });
      this.indexOptions.set(item.id!, index++);
      let groups = item.group!.split(/[,;|]/);
      for (let group of groups) {
        let arr = this.groupOptions.get(group) ?? [];
        arr.push(item.id!);
        this.groupOptions.set(group, arr);
      }
    }
    index = 0;
    for (let key of this.groupOptions.keys()) {
      this.indexOptions.set(key, index++);
    }
    // 拉起选择器
    this.dialogController.open();
  }

  /** 更新历史记录 */
  updateHistory(value: string) {
    // 获取历史索引
    let index = this.histories.indexOf(value);
    // 把已有的历史放到最前面
    if (index >= 0) this.histories.splice(index, 1);
    this.histories.unshift(value);
    // 限制历史数量
    if (this.histories.length > Const.historyCount) {
      this.histories.splice(Const.historyCount);
    }
    // 保存
    site.pf.put(Const.searchHistory, this.histories);
  }

  /** 获取选择项 */
  getSelectContents(index: number = 0): ISheetInfo[] {
    if (index > 0) return this.sourceOptions;
    let arr: ISheetInfo[] = [];
    for (let key of this.groupOptions.keys()) {
      arr.push({ title: key, value: key });
    }
    return arr;
  }

  /** 获取选择项索引 */
  getSelectIndex(index: number = 0): number[] {
    let items = this.selectOptions.get(index) ?? [];
    return items.map((item) => this.indexOptions.get(item) ?? -1)
  }

  /** 确认选择 */
  confirmSelects(index: number, items: Object[]): void {
    this.selectOptions.set(index, items);
    // 空数组是全选
    this.selects.splice(0);
    if (index > 0) {
      // 存储选择的图源id
      this.selects.push(...items as number[]);
    } else if (items.length != this.groupOptions.length) {
      // 存储选择的分组
      this.selects.push(...items as string[]);
    }
    // 保存
    site.pf.put(Const.searchSelects, this.selects);
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
    this.dataSource.clear();
    this.dataSource.pushAll(items);
  }
}