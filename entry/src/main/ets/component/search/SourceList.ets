import { LengthMetrics } from '@kit.ArkUI';
import { IDiscoverItemRule, IDiscoverRule } from '../../common';
import { UDataSource } from '../../common/Data';
import { Log } from '../../helpers';
import { SearchResultItem } from '../../models/Result';

@Component
export struct SourceResultList {
  /** 图片间距 */
  static readonly itemGap = 10;
  /** 图源源中的发现规则 */
  @Prop
  discoverRule: IDiscoverRule;
  /** 图源发现项规则 */
  @Prop
  item: IDiscoverItemRule;
  /** Grid 滚动控制器 */
  private scroller: Scroller = new Scroller();
  /** Grid 滚动控制器 */
  private dataSource: UDataSource<SearchResultItem> = new UDataSource<SearchResultItem>();
  /** 数据加载中 */
  private loading: boolean = false;

  aboutToAppear(): void {
    Log.i('SearchList aboutToAppear');
  }

  build() {
    WaterFlow({ scroller: this.scroller }) {
      /*LazyForEach(this.dataSource, (item: SourceItem) => {
        Row() {
        }
      })*/
      ForEach(Array(30).fill(0).flat(), (item: ResourceStr, i) => {
        FlowItem() {
          Image(item).width('100%')
        }
      })
    }
    .columnsTemplate('repeat(auto-fit, 240)')
    .columnsGap(SourceResultList.itemGap)
    .rowsGap(SourceResultList.itemGap)
    .edgeEffect(EdgeEffect.Spring)
    .scrollBarWidth(2)
    .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(40) })
    .onScrollIndex((first: number, last: number) => {
      // 即将触底时提前增加数据
      if (last + 20 >= 60 && this.loading === false) {
        this.loading = true;
        Log.i('即将触底');
      }
    })

    // 添加加载中动画组件
  }
}