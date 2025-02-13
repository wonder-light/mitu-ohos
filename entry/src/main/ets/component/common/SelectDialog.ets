import { TitleBar } from '..';
import { Const } from '../../common';
import { Callback2 } from '../../common/Type';
/** Sheet 信息 */
export declare interface ISheetInfo {
  /** 标题 */
  title: ResourceStr;

  /** 内容: 分组名称, 以及对应内容列表 */
  value: Object;
}

/** SelectDialog.contents 的接口 */
export declare interface IContentInfo {
  /** 分组名称 */
  name?: ResourceStr;

  /** 是否单选, 默认为 true */
  isRadio?: boolean;

  /** 设置 SelectDialog 选定索引 */
  selectedIndex?: number[] | Callback<void, number[]>;

  /** 内容列表 */
  contents: ISheetInfo[] | Callback<void, ISheetInfo[]>;
}

/**
 * 选择对话框
 */
@Component
@CustomDialog
export struct SelectDialog {
  /** 弹窗控制器 */
  declare dialogController: CustomDialogController;
  /** 标题 */
  title?: ResourceStr;
  /** SelectDialog 的数据选项 */
  options: IContentInfo[] = [];
  /** 确认按钮的回调 */
  onConfirm?: Callback2<number, Object[]>;
  /** 当前选中的索引 */
  @State
  private currentIndex: number = 0;
  /** 多选框的选中状态 */
  @State
  private selectState: Map<number, boolean> = new Map();
  /** 选中的索引 */
  private selectIndex: Map<number, Set<number>> = new Map();
  //
  private _accent = $r('app.color.accent');
  private _tabHeight = 32;
  private _divider = $r('app.color.button_divider');
  private _selectAll = $r('app.string.select_all');
  private _notSelectAll = $r('app.string.not_select_all');
  private _prefix = '';

  aboutToAppear(): void {
    this._prefix = `select_dialog_${this.getUniqueId()}_`;
    this.options.forEach((option, index) => {
      if (this.selectIndex.has(index)) return;
      let items = new Set<number>(this.getSelectedIndex(option));
      this.selectState.set(index, items.size == 0 ? false : true);
      this.selectIndex.set(index, items);
    })
  }

  build() {
    Column() {
      // TODO: 可以添加搜搜按钮, 用于搜索项目
      TitleBar({ title: this.title, maxMenuCount: 2, enableBack: false })
      Column() {
        if (this.options.length > 1) {
          Tabs() {
            ForEach(this.options, (content: IContentInfo, index: number) => {
              TabContent() {
                this.buildList(content, index)
              }.tabBar(this.buildTabBar(index, content.name))
            })
          }
          .height('auto')
          .barHeight(this._tabHeight + 6)
          .animationDuration(Const.animate.duration)
          .onAnimationStart((_, index: number) => animateTo(Const.animate, () => this.currentIndex = index))
        } else if (this.options.length > 0) {
          this.buildList(this.options[0], 0)
        }
      }
      .padding(10)
      .flexGrow(1)
      .flexShrink(1)
      .flexBasis('0%')

      Row() {
        if (this.options[this.currentIndex]?.isRadio === false) {
          Row() {
            CheckboxGroup({ group: this._prefix + this.currentIndex })
              .margin({ left: 6, right: 6 })
              .selectedColor(this._accent)
              .onChange((event) => {
                this.selectState.set(this.currentIndex, event.status !== SelectStatus.None);
              })
            Text(this.selectState.get(this.currentIndex) ? this._notSelectAll : this._selectAll)
              .fontColor(this._accent)
          }
          .width(60)
        }

        Button($r('app.string.cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor(this._divider)
          .onClick(() => this.dialogController.close())

        Button($r('app.string.confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor(this._accent)
          .onClick(() => this.confirm())
      }
      .width('100%')
      .height('auto')
      .backgroundColor($r('app.color.background'))
      .padding(8)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  /** 构建 TabBar */
  @Builder
  buildTabBar(index: number, name?: ResourceStr) {
    Button(name, { buttonStyle: ButtonStyleMode.TEXTUAL })
      .width('100%')
      .height(this._tabHeight)
      .fontColor(this.currentIndex === index ? $r('app.color.icon_on') : $r('app.color.font'))
      .backgroundColor(this.currentIndex === index ? this._accent : Color.Transparent)
      .border(this.currentIndex !== index ? { width: 1, color: this._divider } : { width: 0 })
  }

  /** 构建内容列表 */
  @Builder
  buildList(option: IContentInfo, index: number) {
    List({ space: 4 }) {
      Repeat(Array.isArray(option.contents) ? option.contents : option.contents()).each((item) => {
        ListItem() {
          Row() {
            if (option.isRadio ?? true) {
              Radio({ value: item.item.value.toString(), group: this._prefix + index })
                .checked(this.selectIndex.get(index)?.has(item.index))
                .radioStyle({ checkedBackgroundColor: this._accent })
                .onChange((isChecked) => {
                  let set = this.selectIndex.get(index);
                  isChecked ? set?.add(item.index) : set?.delete(item.index);
                })
            } else {
              Checkbox({ name: item.item.value.toString(), group: this._prefix + index })
                .select(this.selectIndex.get(index)?.has(item.index))
                .selectedColor(this._accent)
                .onChange((isChecked) => {
                  let set = this.selectIndex.get(index);
                  isChecked ? set?.add(item.index) : set?.delete(item.index);
                })
            }
            Text(item.item.title).margin({ left: 6 })
          }
        }
      }).virtualScroll()
    }
    .width('auto')
    .height('auto')
    .displayPriority(5)
  }

  /** 获取选中项 */
  protected confirm() {
    // 没有时直接关闭
    if (!this.onConfirm) {
      this.dialogController.close();
      return;
    }
    // 获取当前 Tab 页的选项
    let option = this.options[this.currentIndex];
    let contents = Array.isArray(option.contents) ? option.contents : option.contents();
    // 获取值
    let items: Object[] = [];
    for (let item of this.selectIndex.get(this.currentIndex) ?? []) {
      items.push(contents[item].value);
    }
    // 回调
    this.onConfirm(this.currentIndex, items);
    this.dialogController.close();
  }

  /** 获取选中项索引 */
  protected getSelectedIndex(option: IContentInfo): number[] {
    const isRadio = option.isRadio ?? true;
    let items: number[];
    if (!option.selectedIndex) {
      items = [];
    } else {
      items = Array.isArray(option.selectedIndex) ? option.selectedIndex : option.selectedIndex();
      if (isRadio && items.length > 1) {
        items.splice(1);
      }
    }
    return items;
  }
}