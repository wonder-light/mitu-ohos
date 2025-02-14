import { LengthMetrics } from '@kit.ArkUI';
/**
 * 标题栏菜单项
 * @module TitleBar
 */
export declare interface TitleBarMenuItem {
  /**
   * 此菜单项的图标资源.
   */
  value?: ResourceStr;

  /**
   * 此菜单项的图标标签.
   */
  label?: ResourceStr;

  /**
   * 定义项目类型
   */
  enable?: boolean;

  /**
   * 单击此菜单项时的回调函数.
   */
  action?: () => void;

  /**
   * 创建自定义构建.
   */
  builder?: CustomBuilder;
}

/**
 * 标题栏
 */
@Component
export struct TitleBar {
  static readonly imageSize = $r('app.float.icon_size');
  static readonly imageHotZoneWidth = 40;
  static readonly buttonBorderRadius = 8;
  static readonly totalHeight = 50;
  static readonly leftPadding = 12;
  static readonly PUBLIC_BACK: Resource = $r('sys.symbol.arrow_left');
  /** 图片项 */
  item: TitleBarMenuItem | undefined = undefined;
  /** 标题 */
  title: ResourceStr | undefined = undefined;
  /** 子标题 */
  subtitle: ResourceStr | undefined = undefined;
  /** 菜单项 */
  menuItems: Array<TitleBarMenuItem> = [];
  /** 菜单项显示的最大数量 */
  maxMenuCount: number = 3;
  /** 启用返回按钮 */
  enableBack: boolean = false;
  /** 返回操作 */
  backCall: VoidCallback | undefined;
  /** 背景色 */
  bgColor: ResourceColor = $r('app.color.accent');
  /** 自定义标题组件 */
  @BuilderParam
  customTitle: undefined | (() => void);
  /** 自定义菜单组件 */
  @BuilderParam
  customPopup: (() => void) = this.menuBuilder;
  /** 是否显示菜单弹窗 */
  @State
  private showPopup: boolean = false;

  aboutToAppear(): void {
    if (this.enableBack && this.backCall == null) {
      const uiContext: UIContext = this.getUIContext();
      const uniqueId: number = this.getUniqueId();
      const pageStack = uiContext.getNavigationInfoByUniqueId(uniqueId)?.pathStack;
      this.backCall = () => pageStack?.pop();
    }
  }

  build() {
    Row({ space: TitleBar.leftPadding }) {
      Row({ space: TitleBar.leftPadding }) {
        if (this.enableBack) {
          ImageButton({ item: { value: TitleBar.PUBLIC_BACK, action: this.backCall } })
        }

        if (this.item !== undefined) {
          Image(this.item.value)
            .width(TitleBar.imageHotZoneWidth)
            .height(TitleBar.imageHotZoneWidth)
            .focusable(false)
            .borderRadius(TitleBar.buttonBorderRadius)
        }

        Column() {
          if (this.customTitle !== undefined) {
            this.customTitle()
          } else {
            if (this.title !== undefined) {
              Text(this.title)
                .fontWeight(FontWeight.Medium)
                .fontSize($r('app.float.text_xl'))
                .fontColor($r('app.color.font'))
                .maxLines(this.subtitle !== undefined ? 1 : 2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            if (this.subtitle !== undefined) {
              Text(this.subtitle)
                .fontSize($r('app.float.text_sm'))
                .fontColor($r("app.color.fontSecondary"))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
        }
        .flex()
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .flex()

      if (this.menuItems.length > 0) {
        Row() {
          ForEach(this.menuItems.slice(0, this.maxMenuCount), (item: TitleBarMenuItem, index: number) => {
            ImageButton({ item: item, customBuild: item.builder instanceof Function ? item.builder : undefined })
          })

          if (this.menuItems.length > this.maxMenuCount) {
            ImageButton({
              item: {
                value: $r('sys.media.ohos_ic_public_more'),
                action: () => this.showPopup = !this.showPopup
              }
            }).bindMenu(this.showPopup, this.customPopup, {
              onDisappear: () => this.showPopup = false
            })
          }
        }
      }
    }
    .width('100%')
    .constraintSize({ minHeight: TitleBar.totalHeight })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignSelf(ItemAlign.Stretch)
    .padding({ left: TitleBar.leftPadding, right: TitleBar.leftPadding })
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  menuBuilder() {
    Menu() {
      ForEach(this.menuItems.slice(this.maxMenuCount), (item: TitleBarMenuItem, index: number) => {
        if (item.builder != null) {
          MenuItem(item.builder).onClick(() => item.action?.())
        } else {
          MenuItem({ startIcon: item.value, content: item.label }).onClick(() => item.action?.())
        }
      })
    }
    .backgroundColor($r('app.color.background'))
  }

  @Styles
  flex(){
    .flexGrow(1)
    .flexShrink(1)
    .flexBasis('0%')
  }
}

@Reusable
@Component
export struct ImageButton {
  static readonly space: LengthMetrics = LengthMetrics.vp(4);
  static font: ResourceColor = $r('app.color.font');
  /** 菜单项 */
  @Prop
  item: TitleBarMenuItem;
  /** 定义文本fontColor */
  @Prop
  textColor?: ResourceColor = ImageButton.font;
  /** 定义图标填充颜色 */
  @Prop
  iconColor?: ResourceColor = ImageButton.font;
  /** 定义命中测试模式 */
  hitTest: HitTestMode = HitTestMode.Default;
  /** 设置元素的水平布局 */
  textDirection?: FlexDirection = FlexDirection.Column;
  /** 自定义组件 */
  @BuilderParam
  customBuild: undefined | (() => void);

  build() {
    if (this.customBuild != null) {
      this.customBuild()
    } else {
      Button({
        type: this.item.label != null ? ButtonType.Normal : ButtonType.Circle,
        stateEffect: this.item.enable !== false
      }) {
        if (!this.item.label) {
          this.buildImage()
        } else {
          Flex({
            direction: this.textDirection,
            space: { main: ImageButton.space, cross: ImageButton.space },
            justifyContent: FlexAlign.Center,
            alignContent: FlexAlign.Center,
            alignItems: ItemAlign.Center
          }) {
            this.buildImage()
            Text(this.item.label)
              .fontSize($r('app.float.text_xs'))
              .maxLines(1)
              .fontColor(this.textColor)//.colorBlend(this.textColor)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
      }
      .enabled(this.item.enable !== false)
      .stateStyles({
        normal: {
          .foregroundColor(Color.Transparent)
          .backgroundColor(Color.Transparent)
        },
        clicked: {
          .foregroundColor($r('app.color.button_normal'))
          .backgroundColor($r('app.color.button_normal'))
        }
      })
      .borderRadius(this.item.label != null ? 8 : null)
      .width(this.item.label != null ? '100%' : TitleBar.imageHotZoneWidth)
      .height(this.item.label != null ? '100%' : TitleBar.imageHotZoneWidth)
      .align(Alignment.Center)
      .hitTestBehavior(this.hitTest)
      .onClick(this.item.action)
    }
  }

  @Builder
  buildImage() {
    if (this.isSymbolResource(this.item.value)) {
      SymbolGlyph(this.item.value as Resource)
        .draggable(false)
        .fontColor([this.iconColor])
      //.colorBlend(this.iconColor)
    } else {
      Image(this.item.value)
        .draggable(false)
        .matchTextDirection(true)
        .width(TitleBar.imageSize)
        .height(TitleBar.imageSize)
        .fillColor(this.iconColor)
      //.colorBlend(this.iconColor)
    }
  }

  /** 判断是否是符号资源 */
  isSymbolResource(value?: ResourceStr) {
    if (typeof value === 'string' || typeof value === 'undefined') {
      return false;
    }
    return (value as Resource)?.type == 40000;
  }
}