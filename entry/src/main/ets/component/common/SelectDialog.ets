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
  static readonly tabHeight = Const.fPadding8;
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
  /** 分组前缀 */
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
              }
              .tabBar(this.buildTabBar(index, content.name))
              .flex()
            })
          }
          .height('auto')
          .flex()
          .barHeight(SelectDialog.tabHeight)
          .animationDuration(Const.animate.duration)
          .onAnimationStart((_, index: number) => animateTo(Const.animate, () => this.currentIndex = index))
        } else if (this.options.length > 0) {
          this.buildList(this.options[0], 0)
        }
      }
      .padding(Const.fPadding2)
      .flex()

      RelativeContainer() {
        if (this.options[this.currentIndex]?.isRadio === false) {
          Row() {
            CheckboxGroup({ group: this._prefix + this.currentIndex })
              .margin({ left: Const.fPadding2, right: Const.fPadding2 })
              .selectedColor(Const.cPrimary)
              .onChange((event) => {
                this.selectState.set(this.currentIndex, event.status !== SelectStatus.None);
              })
            Text(this.selectState.get(this.currentIndex) ? $r('app.string.not_select_all') : $r('app.string.select_all'))
              .fontColor(Const.cPrimary)
          }
          .alignRules(this.getAligns(-1))
        }

        Button($r('app.string.cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor(Const.cFontSecondary)
          .onClick(() => this.dialogController.close())
          .alignRules(this.getAligns(this.options[this.currentIndex]?.isRadio === false ? 0 : -1))

        Button($r('app.string.confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor(Const.cPrimary)
          .onClick(() => this.confirm())
          .id(this._prefix + 'confirm')
          .alignRules(this.getAligns(1))
      }
      .width('100%')
      .height('auto')
      .padding({ left: Const.fPadding2, right: Const.fPadding2 })
    }
    .padding({ bottom: Const.fPadding2 })
    .backgroundColor(Const.cBackground)
  }

  /** 构建 TabBar */
  @Builder
  buildTabBar(index: number, name?: ResourceStr) {
    Button(name, { buttonStyle: ButtonStyleMode.TEXTUAL })
      .width('100%')
      .height(SelectDialog.tabHeight - 6)
      .fontColor(this.currentIndex === index ? Const.cIconOn : Const.cFont)
      .backgroundColor(this.currentIndex === index ? Const.cPrimary : Color.Transparent)
      .border(this.currentIndex !== index ? { width: 1, color: Const.cButtonDivider } : { width: 0 })
  }

  /** 构建内容列表 */
  @Builder
  buildList(option: IContentInfo, index: number) {
    List({ space: Const.fPadding1 }) {
      Repeat(Array.isArray(option.contents) ? option.contents : option.contents()).each((item) => {
        ListItem() {
          Row() {
            if (option.isRadio ?? true) {
              Radio({ value: item.item.value.toString(), group: this._prefix + index })
                .checked(this.selectIndex.get(index)?.has(item.index))
                .radioStyle({ checkedBackgroundColor: Const.cPrimary })
                .onChange((isChecked) => {
                  let set = this.selectIndex.get(index);
                  isChecked ? set?.add(item.index) : set?.delete(item.index);
                })
            } else {
              Checkbox({ name: item.item.value.toString(), group: this._prefix + index })
                .select(this.selectIndex.get(index)?.has(item.index))
                .selectedColor(Const.cPrimary)
                .onChange((isChecked) => {
                  let set = this.selectIndex.get(index);
                  isChecked ? set?.add(item.index) : set?.delete(item.index);
                })
            }
            Text(item.item.title).margin({ left: Const.fPadding2 })
          }
        }
      }).virtualScroll()
    }
    .width('auto')
    .height('auto')
    .flex()
  }

  @Styles
  flex() {
    .flexGrow(1)
    .flexShrink(1)
    .flexBasis('0%')
  }

  /**
   * 获取对齐规则\
   * option < 0, 对齐左边\
   * option = 0, 对齐中间\
   * option > 0, 对齐右边
   */
  protected getAligns(option: number): AlignRuleOption {
    let item: AlignRuleOption = { center: { anchor: this._prefix + 'confirm', align: VerticalAlign.Center } };
    if (option < 0) {
      item.left = { anchor: '__container__', align: HorizontalAlign.Start }
    } else if (option > 0) {
      item.center = undefined;
      item.right = { anchor: '__container__', align: HorizontalAlign.End }
    } else {
      item.middle = { anchor: '__container__', align: HorizontalAlign.Center };
    }
    return item
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