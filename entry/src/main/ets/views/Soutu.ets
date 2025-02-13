import { BaseDao } from '@ohos/dataorm';
import { Const, IDiscoverItemRule, IPictureSource } from '../common';
import { ISheetInfo, Loading, SelectDialog, SourceResultList, TItemCallback, TitleBar, TitleBarMenuItem } from '../component';
import { site } from '../helpers';
import { PictureSource } from '../models';
import { SearchResultItem } from '../models/Result';

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
      action: () => this.pageStack.pushPathByName(Const.search, null, true)
    },
    {
      label: $r("app.string.source_manage"),
      action: () => this.pageStack.pushPathByName(Const.sourceManage, null, true)
    },
    {
      label: $r("app.string.switch_source"),
      action: () => this.openSwitchSource()
    }
  ];
  /** 是否正在加载源数据 */
  @State
  isLoading: boolean = true;
  // 数据源
  @State
  source: PictureSource = new PictureSource();
  /** 页面是否正在进入 */
  @State
  private _pageEnter: boolean = false;
  private _navDestinationId?: string;
  /** 弹窗控制器 */
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: $r('app.string.switch_source'),
      options: [{ contents: () => this.getSelectContents(), selectedIndex: () => this.getSelectIndex() }],
      onConfirm: (_, items) => this.loadData(items.shift() as number | undefined)
    }),
    cornerRadius: 16
  });
  /** 弹窗的选项列表 */
  private selectContents: ISheetInfo[] = [];
  /** 数据源 */
  declare private dao: BaseDao<PictureSource, number>;

  aboutToAppear(): void {
    this.loadData();
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu"), maxMenuCount: 1, menuItems: this.navMenus })
      Column() {
        if (this.isLoading) {
          Loading()
        } else if (!this.source || this.source.discoverRule.urlRules.length <= 0) {
          Text($r('app.string.no_set_rule'))
        } else {
          Tabs() {
            ForEach(this.source.discoverRule.urlRules, (rule: IDiscoverItemRule) => {
              TabContent() {
                SourceResultList({ generateData: (data) => this.generateData(data, rule) })
                  .width('100%')
                  .height('100%')
              }
              .tabBar(this.getTabBarStyle(rule.name))
            })
          }
          .scrollable(true)
          .barHeight(40)
          .barMode(BarMode.Scrollable, { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_AVERAGE_SPLIT })
          .animationDuration(300)
          .fadingEdge(true)
        }
      }
      .height('100%')
      .flexGrow(1)
      .flexShrink(1)
      .flexBasis('0%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .opacity(this._pageEnter ? 0 : 1)
    .onDisAppear(() => site.unregisterNavTransition(this._navDestinationId!))
    .onReady((ctx) => {
      site.registerNavTransition(this._navDestinationId = ctx.navDestinationId!, {
        onInit: (isExit) => this._pageEnter = !isExit,
        onEnd: (isExit) => this._pageEnter = isExit
      });
    })
  }

  /**
   * 获取 TabBar 样式
   * @param name
   * @returns
   */
  getTabBarStyle(name: ResourceStr): SubTabBarStyle {
    return SubTabBarStyle.of(name)
      .padding(0)
      .indicator({ color: $r('app.color.accent'), marginTop: 2 })
      .labelStyle({
        selectedColor: $r('app.color.accent'),
        heightAdaptivePolicy: TextHeightAdaptivePolicy.MAX_LINES_FIRST
      })
  }

  /** 打开切换图源的弹窗页面 */
  async openSwitchSource(): Promise<void> {
    // 获取数据源
    let results = await this.dao.queryBuilder().select('id', 'name').listSqlAs<IPictureSource>();
    // 设置弹窗的选项数据
    this.selectContents = results.map((item): ISheetInfo => ({ title: item.name!, value: item.id! }));
    this.dialogController.open();
  }

  /** 获取选中的索引 */
  private getSelectIndex(): number[] {
    let index = this.selectContents.findIndex((item) => item.value == this.source.id);
    if (index < 0) index = 0;
    return [index];
  }

  /** 获取弹窗的选项 */
  private getSelectContents(): ISheetInfo[] {
    return this.selectContents;
  }

  /** 加载初始数据 */
  private async loadData(id: number = -1): Promise<void> {
    animateTo(Const.animate, () => this.isLoading = true);
    // 加载搜图页面的初始图片源
    this.dao ??= site.db.getBaseDao<PictureSource, number>(PictureSource);
    // 从本地数据中加载一次 id
    if (id < 0) id = await site.pf.get(Const.soutu, id) as number;
    // 从数据库中取出第一个的 id
    if (id < 0) {
      let items = await this.dao.queryBuilder()
        .select('id')
        .limit(1)
        .listSqlAs<IPictureSource>();
      id = items.shift()?.id ?? -1;
    }
    // id < 0 则不改变 this.source, id >= 0 则加载数据
    if (id >= 0) {
      // 加载数据
      let source = await this.dao.loadDeep(id);
      // 记录
      if (source) {
        this.source = source;
        await site.pf.put(Const.soutu, this.source.id);
      }
    }
    animateTo(Const.animate, () => this.isLoading = false);
  }

  /**
   * 生成的数据
   * @param callback 添加数据的回调
   * @param rule 发现项规则
   */
  private generateData(callback: TItemCallback, rule: IDiscoverItemRule): void {
    // 发现规则
    let discoverRule = this.source?.discoverRule;
    let fill = new SearchResultItem({
      thumbnail: 'https://images4.alphacoders.com/133/thumb-440-1335428.webp',
      origin: 'https://images4.alphacoders.com/133/thumb-1920-1335428.png'
    });
    let items = Array<SearchResultItem>(20).fill(fill);
    callback(items);
  }
}