import { ComposeTitleBarMenuItem } from '@kit.ArkUI';

export type TitleBarMenuItem = ComposeTitleBarMenuItem;

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
  /** 启用返回按钮 */
  enableBack: boolean = false;
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
      if (this.pageStack != null && this.pageStack?.getAllPathName().length > 1) {
        this.hasBack = true;
      }
    }
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Stretch }) {
      Row({ space: TitleBar.leftPadding }) {
        if (this.enableBack && this.hasBack) {
          this.buildMenuItem({
            value: TitleBar.PUBLIC_BACK,
            action: () => this.pageStack?.pop()
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
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .flexGrow(1)

      if (this.menuItems.length > 0) {
        Row() {
          ForEach(this.menuItems, (item: TitleBarMenuItem, index: number) => {
            this.buildMenuItem(item)
          })
        }
      }
    }
    .width('100%')
    .height(TitleBar.totalHeight)
    .padding({ left: $r('sys.float.ohos_id_default_padding_start'), right: $r('sys.float.ohos_id_default_padding_start') })
    .backgroundColor($r('sys.color.ohos_id_color_background'))
  }

  @Builder
  buildMenuItem(item: TitleBarMenuItem) {
    Button({ type: ButtonType.Circle, stateEffect: item.isEnabled ?? true }) {
      if (this.isSymbolResource(item.value)) {
        SymbolGlyph(item.value as Resource)
          .draggable(false)
          .focusable(item.isEnabled ?? true)
          .focusable(item.isEnabled ?? true)
          .fontColor([$r('sys.color.ohos_id_color_text_primary')])
      } else {
        Image(item.value)
          .draggable(false)
          .matchTextDirection(true)
          .width(TitleBar.imageSize)
          .height(TitleBar.imageSize)
          .focusable(item.isEnabled ?? true)
          .fillColor($r('sys.color.ohos_id_color_text_primary'))
      }
    }
    .enabled(item.isEnabled ?? true)
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
      return (item.isEnabled ?? true) && item.action?.();
    })
  }

  isSymbolResource(value: ResourceStr) {
    if (typeof value === 'string' || typeof value === 'undefined') {
      return false;
    }
    return (value as Resource)?.type == 40000;
  }
}