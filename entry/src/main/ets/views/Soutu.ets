import { emitter } from '@kit.BasicServicesKit';
import { BaseDao } from '@ohos/dataorm';
import { Const, IDiscoverItemRule } from '../common';
import { Loading, SourceResultList, TItemCallback, TitleBar, TitleBarMenuItem } from '../component';
import { site } from '../helpers';
import { DiscoverItemRule, PictureSource } from '../models';
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
      action: (): void => this.pageStack.pushPathByName(Const.search, false, true)
    },
    {
      value: $r('app.media.camera'),
      action: (): void => this.pageStack.pushPathByName(Const.search, true, true)
    }
  ];
  /** 是否正在加载 */
  @State
  private isLoading: boolean = true;
  // 数据源
  @State
  private source?: PictureSource = new PictureSource();
  /** Tabs 控制器 */
  private controller: TabsController = new TabsController();
  /** 数据源 */
  declare private dao: BaseDao<PictureSource, number>;

  aboutToAppear(): void {
    this.loadData();
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.soutu"), menuItems: this.navMenus })
      Column() {
        if (this.isLoading) {
          Loading()
        } else if (!this.source || this.source.discoverRule.urlRules.length <= 0) {
          Text($r('app.string.no_set_rule'))
        } else {
          Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
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
      .height(`calc(100% - ${TitleBar.totalHeight}vp)`)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  /**
   * 加载初始数据
   */
  async loadData(): Promise<void> {
    // 判断 site.db 是否已经初始化
    if (!site.db) {
      return emitter.on(Const.siteInit, () => this.loadData());
    }
    // 加载搜图页面的初始图片源
    let id: number = await site.pf.get(Const.soutu, -1) as number;
    this.dao = site.db.getBaseDao<PictureSource, number>(PictureSource);
    if (id < 0) {
      let items = await this.dao.queryBuilder().limit(1).list();
      this.source = items.shift();
      // 记录
      if (this.source) await site.pf.put(Const.soutu, this.source.id);
    } else {
      this.source = await this.dao.loadDeep(id);
    }
    // TODO: 需要删除
    if (!this.source) this.source = new PictureSource();
    this.source.discoverRule.urlRules.push(...[
      new DiscoverItemRule({ name: '必应' }),
      new DiscoverItemRule({ name: '百度' }),
      new DiscoverItemRule({ name: 'Pixiv' })
    ]);
    this.isLoading = false;
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

  /**
   * 生成的数据
   * @param callback 添加数据的回调
   * @param rule 发现项规则
   */
  generateData(callback: TItemCallback, rule: IDiscoverItemRule): void {
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