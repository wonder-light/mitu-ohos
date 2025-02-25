import { LengthMetrics } from '@kit.ArkUI';
import { Const, TCustomBuilder } from '../../common';
import { CustomItem } from './Custom';
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
  builder?: TCustomBuilder;
}

/**
 * 标题栏
 */
@Component
export struct TitleBar {
  static readonly PUBLIC_BACK: Resource = $r('sys.symbol.arrow_left');
  /** 图片项 */
  item?: TitleBarMenuItem = undefined;
  /** 标题 */
  title?: ResourceStr = undefined;
  /** 子标题 */
  subtitle?: ResourceStr = undefined;
  /** 菜单项 */
  menuItems: Array<TitleBarMenuItem> = [];
  /** 菜单项显示的最大数量 */
  maxMenuCount: number = 3;
  /** 启用返回按钮 */
  enableBack: boolean = false;
  /** 返回操作 */
  backCall?: VoidCallback = undefined;
  /** 背景色 */
  bgColor: ResourceColor = Const.cAccent;
  /** 自定义标题组件 */
  @BuilderParam
  customTitle?: () => void;
  /** 自定义菜单组件 */
  @BuilderParam
  customPopup?: () => void = this.menuBuilder;
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
    Row({ space: Const.fPadding3 }) {
      Row({ space: Const.fPadding3 }) {
        if (this.enableBack) {
          ImageButton({ item: { value: TitleBar.PUBLIC_BACK, action: this.backCall } })
        }

        if (this.item !== undefined) {
          Image(this.item.value)
            .width(Const.fImageButton)
            .height(Const.fImageButton)
            .focusable(false)
            .borderRadius(Const.fPadding2)
        }

        Column() {
          if (this.customTitle !== undefined) {
            this.customTitle()
          } else {
            if (this.title !== undefined) {
              Text(this.title)
                .fontWeight(FontWeight.Medium)
                .fontSize(Const.fTextXl)
                .fontColor(Const.cFont)
                .maxLines(this.subtitle !== undefined ? 1 : 2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            if (this.subtitle !== undefined) {
              Text(this.subtitle)
                .fontSize(Const.fTextSm)
                .fontColor(Const.cFontSecondary)
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
            if (item.builder !== undefined) {
              CustomItem({ builder: item.builder, params: [item, index] })
            } else {
              ImageButton({ item: item })
            }
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
    .constraintSize({ minHeight: Const.fTitleBarHeight })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignSelf(ItemAlign.Stretch)
    .padding({ left: Const.fPadding3, right: Const.fPadding3 })
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
    .backgroundColor(Const.cBackground)
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
  static readonly space: LengthMetrics = LengthMetrics.vp(Const.fPadding1);
  /** 菜单项 */
  @Prop
  item: TitleBarMenuItem;
  /** 定义文本fontColor */
  @Prop
  textColor?: ResourceColor = Const.cFont;
  /** 定义图标填充颜色 */
  @Prop
  iconColor?: ResourceColor = Const.cFont;
  /** 定义命中测试模式 */
  hitTest: HitTestMode = HitTestMode.Default;
  /** 设置元素的水平布局 */
  textDirection?: FlexDirection = FlexDirection.Column;

  build() {
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
            .fontSize(Const.fTextXs)
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
        .foregroundColor(Const.cButtonNormal)
        .backgroundColor(Const.cButtonNormal)
      }
    })
    .borderRadius(this.item.label != null ? Const.fPadding2 : null)
    .width(this.item.label != null ? '100%' : Const.fImageButton)
    .height(this.item.label != null ? '100%' : Const.fImageButton)
    .align(Alignment.Center)
    .hitTestBehavior(this.hitTest)
    .onClick(this.item.action)
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
        .width(Const.fIconSize)
        .height(Const.fIconSize)
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