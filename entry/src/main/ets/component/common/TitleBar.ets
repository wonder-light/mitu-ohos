/**
 * 标题栏菜单项
 * @module TitleBar
 */
export declare class TitleBarMenuItem {
  /**
   * 此菜单项的图标资源.
   */
  value?: ResourceStr;
  /**
   * 此菜单项的图标标签.
   */
  label?: ResourceStr;
  /**
   * 是否启用此菜单项.
   */
  isEnabled?: boolean;
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
  private static readonly totalHeight = 50;
  private static readonly leftPadding = 12;
  private static readonly PUBLIC_BACK: Resource = $r('sys.symbol.arrow_left');
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
  /** 自定义标题组件 */
  @BuilderParam
  customTitle: undefined | (() => void);
  /** 自定义菜单组件 */
  @BuilderParam
  customPopup: (() => void) = this.menuBuilder;
  /** 标题的最大宽度 */
  @State
  private titleMaxWidth: number = 0;
  /** 是否显示菜单弹窗 */
  @State
  private showPopup: boolean = false;
  /** 是否具有返回按钮 */
  private hasBack: boolean = false;
  /** 导航栈 */
  private pageStack: NavPathStack | undefined = undefined;

  aboutToAppear(): void {
    if (this.enableBack) {
      const uiContext: UIContext = this.getUIContext();
      const uniqueId: number = this.getUniqueId();
      //const pageInfo = uiContext.getPageInfoByUniqueId(uniqueId);
      //Log.i('pageInfo: ' + JSON.stringify(pageInfo));
      this.pageStack = uiContext.getNavigationInfoByUniqueId(uniqueId)?.pathStack;
      if (this.pageStack != null && this.pageStack?.getAllPathName().length >= 1) {
        this.hasBack = true;
      }
    }
  }

  build() {
    Row({ space: TitleBar.leftPadding }) {
      Row({ space: TitleBar.leftPadding }) {
        if (this.enableBack && this.hasBack) {
          ImageMenuItem({
            item: {
              value: TitleBar.PUBLIC_BACK,
              action: () => this.pageStack?.pop()
            }
          })
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
                .fontSize($r('sys.float.ohos_id_text_size_headline8'))
                .fontColor($r('sys.color.ohos_id_color_titlebar_text'))
                .maxLines(this.subtitle !== undefined ? 1 : 2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            if (this.subtitle !== undefined) {
              Text(this.subtitle)
                .fontSize($r('sys.float.ohos_id_text_size_over_line'))
                .fontColor($r('sys.color.ohos_id_color_titlebar_subtitle_text'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .constraintSize({ maxWidth: this.titleMaxWidth })
      }
      .flexGrow(1)
      .onAreaChange((_, newArea) => {
        let width = Number(newArea.width)
        width -= (TitleBar.leftPadding + TitleBar.imageHotZoneWidth) * (this.item !== undefined ? 2 : 1);
        this.titleMaxWidth = width;
      })

      if (this.menuItems.length > 0) {
        Row() {
          ForEach(this.menuItems.slice(0, this.maxMenuCount), (item: TitleBarMenuItem, index: number) => {
            ImageMenuItem({ item: item, customBuild: item.builder instanceof Function ? item.builder : undefined })
          })

          if (this.menuItems.length > this.maxMenuCount) {
            ImageMenuItem({
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
    .height(TitleBar.totalHeight)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignSelf(ItemAlign.Stretch)
    .padding({ left: $r('sys.float.ohos_id_default_padding_start'), right: $r('sys.float.ohos_id_default_padding_start') })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }

  @Builder
  menuBuilder() {
    Menu() {
      ForEach(this.menuItems.slice(this.maxMenuCount), (item: TitleBarMenuItem, index: number) => {
        if (item.builder != null) {
          MenuItem(item.builder)
        } else {
          MenuItem({ startIcon: item.value, content: item.label })
        }
      })
    }
  }
}

@Component
export struct ImageMenuItem {
  /** 菜单项 */
  @Prop
  item: TitleBarMenuItem;
  /** 自定义组件 */
  @BuilderParam
  customBuild: undefined | (() => void);

  build() {
    if (this.customBuild != null) {
      this.customBuild()
    } else {
      Button({ type: ButtonType.Circle, stateEffect: this.item.isEnabled ?? true }) {
        if (this.isSymbolResource(this.item.value)) {
          SymbolGlyph(this.item.value as Resource)
            .draggable(false)
            .focusable(this.item.isEnabled ?? true)
            .focusable(this.item.isEnabled ?? true)
            .fontColor([$r('sys.color.ohos_id_color_text_primary')])
        } else {
          Image(this.item.value)
            .draggable(false)
            .matchTextDirection(true)
            .width(TitleBar.imageSize)
            .height(TitleBar.imageSize)
            .focusable(this.item.isEnabled ?? true)
            .fillColor($r('sys.color.ohos_id_color_text_primary'))
        }
      }
      .enabled(this.item.isEnabled ?? true)
      .width(TitleBar.imageHotZoneWidth)
      .height(TitleBar.imageHotZoneWidth)
      .stateStyles({
        normal: {
          .foregroundColor(Color.Transparent)
          .backgroundColor(Color.Transparent)
        },
        clicked: {
          .foregroundColor($r('sys.color.ohos_id_color_click_effect'))
          .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        }
      })
      .onClick(() => {
        return (this.item.isEnabled ?? true) && this.item.action?.();
      })
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