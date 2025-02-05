import { LengthMetrics } from '@kit.ArkUI';
import { ImagePreviewController } from '@rv/image-preview';
import { IDiscoverItemRule, IDiscoverRule } from '../../common';
import { UDataSource } from '../../common/Data';
import { SearchResultItem } from '../../models/Result';
import { ImageCom, ImageDialog } from '../index';

@Reusable
@Component
export struct SourceResultList {
  /** 图片间距 */
  static readonly itemGap = 10;
  /** 图源中的发现规则 */
  @Prop
  discoverRule: IDiscoverRule;
  /** 发现项规则 */
  @Prop
  item: IDiscoverItemRule;
  /** 数据刷新中 */
  @State
  private isRefreshing: boolean = false
  /** 数据加载中 */
  @State
  private isLoading: boolean = false;
  /** Grid 滚动控制器 */
  private scroller: Scroller = new Scroller();
  /** 数据懒加载源 */
  private dataSource: UDataSource<SearchResultItem> = new UDataSource<SearchResultItem>();
  /** 预览控制器 */
  private readonly controller: ImagePreviewController = new ImagePreviewController();
  /** 图片弹窗 */
  private readonly dialogController: CustomDialogController = new CustomDialogController({
    builder: ImageDialog({ controller: this.controller }),
    customStyle: true,
    offset: { dx: 0, dy: 0 },
    alignment: DialogAlignment.Center,
    autoCancel: true
  });

  aboutToAppear(): void {
    let fill = new SearchResultItem({
      thumbnail: 'https://images4.alphacoders.com/133/thumb-440-1335428.webp',
      origin: 'https://images4.alphacoders.com/133/thumb-1920-1335428.png'
    });
    this.dataSource.pushAll(Array<SearchResultItem>(20).fill(fill));
    this.controller.setImage(this.dataSource.getAllData().map((item) => item.origin))
      .setCachedCount(1)
      .setAutoResize(true);
  }

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        WaterFlow({ scroller: this.scroller, footer: () => { this.buildFooter() } }) {
          LazyForEach(this.dataSource, (item: SearchResultItem, index: number) => {
            FlowItem() {
              ImageCom({ src: item.thumbnail ?? item.origin })
                .onClick(() => {
                  this.controller.setInitialIndex(index);
                  this.dialogController.open();
                })
            }
          })
        }
        .columnsTemplate('repeat(auto-fit, 240)')
        .columnsGap(SourceResultList.itemGap)
        .rowsGap(SourceResultList.itemGap)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBarWidth(2)
        .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(40) })
        .onReachEnd(() => {
          // 触底时增加数据
          if (this.isLoading === false) {
            this.loadData();
          }
        })
      }
      .onRefreshing(() => this.refreshData())
    }
    .height('100%')
    .padding({ bottom: SourceResultList.itemGap })
  }

  @Builder
  buildFooter() {
    if (this.isLoading) {
      Image($r('app.media.loading_gif'))
        .width('100%')
        .constraintSize({ maxHeight: 80 })
        .objectFit(ImageFit.ScaleDown)
    }
  }

  /**
   * 刷新数据
   */
  async refreshData() {
    await new Promise<void>((resolve) => setTimeout(resolve, 4000));
    this.isRefreshing = false;
  }

  /**
   * 加载数据
   */
  async loadData() {
    const param: AnimateParam = { duration: 300, curve: Curve.Ease };
    animateTo(param, () => this.isLoading = true)
    await new Promise<void>((resolve) => setTimeout(resolve, 4000));
    animateTo(param, () => this.isLoading = false)
  }
}