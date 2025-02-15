import { Const } from '../../common';
import { TitleBarMenuItem } from './TitleBar';

/** 分组项 */
export declare interface IListGroupItem extends TitleBarMenuItem {
  /** 副标题 */
  subtitle?: ResourceStr;

  /** 后缀图标 */
  suffix?: ResourceStr;
}

/** 分组 */
export declare interface IListGroup {
  /** 分组名 */
  group?: ResourceStr;

  /** 分组内容 */
  items: IListGroupItem[];
}

/** 列表组 */
@ComponentV2
export struct ListGroup {
  /** 分组 */
  @Param
  groups: IListGroup[] = [];
  /** ListItemGroup 之间的间距 */
  @Param
  ListSpace?: string | number = 4;
  /** ListItemGroup 之间的间距 */
  @Param
  groupSpace?: string | number = 4;
  /** 设置当前List初次加载时显示区域起始位置的item索引值 */
  @Param
  @Once
  initialIndex?: number = undefined;
  /** 组件内容大小小于组件自身时，是否开启滑动效果 */
  @Param
  alwaysEnabled?: boolean = true;
  /** 分割线宽度 */
  @Param
  dividerWidth: Length = 0;
  /** 分割线边距 */
  @Param
  dividerMargin?: Length = undefined;
  /** 列表项内边距 */
  @Param
  itemPadding?: number | Resource = 12;
  /** 列表项外边距 */
  @Param
  itemMargin?: number | Resource = 8;
  /** 强调前缀图标 */
  @Param
  accentPrefix?: boolean = undefined;
  /** 选择的索引 */
  @Param
  selectIndex?: number = undefined;
  /** 选择时的背景颜色 */
  @Param
  activeColor?: ResourceColor = Const.cButtonActive;

  build() {
    List({ space: this.ListSpace, initialIndex: this.initialIndex }) {
      ForEach(this.groups, (group: IListGroup, index: number) => {
        ListItemGroup({ header: this.buildHead(group.group), space: this.groupSpace, style: ListItemGroupStyle.CARD }) {
          ForEach(group.items, (item: IListGroupItem, itemIndex: number) => {
            ListItem() {
              Button({ type: ButtonType.Normal, buttonStyle: ButtonStyleMode.TEXTUAL }) {
                this.buildItem(item)
              }
              .fontColor(Const.cFont)
              .padding(this.itemPadding)
              .borderRadius(this.itemPadding)
              .width('100%')
              .onClick(item.action)
              .backgroundColor(this.selectIndex === index + itemIndex ? this.activeColor : Const.cBackground)
            }
            .width('100%')
          })
        }
        .width('100%')
        .borderWidth(0.5)
        .borderColor(Const.cButtonNormal)
        .shadow({ color: Const.cButtonNormal, radius: this.itemPadding })
        .backgroundColor(Color.Transparent)
        .divider({
          strokeWidth: this.dividerWidth,
          color: Const.cButtonNormal,
          startMargin: this.dividerMargin,
          endMargin: this.dividerMargin
        })
      })
    }
    .width('100%')
    .height('auto')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: this.alwaysEnabled })
  }

  @Builder
  buildItem(item: IListGroupItem) {
    Row() {
      Image(item.value)
        .borderRadius(999)
        .backgroundColor(this.accentPrefix === true ? Const.cPrimary : undefined)
        .fillColor(this.accentPrefix === true ? Const.cIconOn : Const.cPrimary)
        .width(this.accentPrefix === true ? Const.fIconSizeLg : Const.fIconSize)
        .height(this.accentPrefix === true ? Const.fIconSizeLg : Const.fIconSize)
        .padding(this.accentPrefix === true ? 4 : undefined)
      Column() {
        Text(item.label)
        if (item.subtitle) {
          Text(item.subtitle)
            .fontColor(Const.cFontSecondary)
            .fontSize(Const.fTextSm)
            .margin({ top: this.itemMargin })
        }
      }
      .margin({ left: this.itemMargin, right: this.itemMargin })
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      .flexShrink(1)
      .flexBasis('0%')

      if (item.suffix) {
        Image(item.suffix)
          .width(Const.fIconSize)
          .height(Const.fIconSize)
          .fillColor(Const.cButtonDivider)
      }
    }
    .width('100%')
  }

  @Builder
  buildHead(group?: ResourceStr) {
    if (group) {
      Text(group)
        .fontColor(Const.cPrimary)
        .fontSize(Const.fTextSm)
        .padding({ left: this.itemPadding })
        .margin({ top: 4, bottom: this.itemMargin })
    }
  }
}