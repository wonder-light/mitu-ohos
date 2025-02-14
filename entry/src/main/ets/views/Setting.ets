import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { Const } from '../common';
import { SelectDialog, TitleBar, TitleBarMenuItem } from '../component';
import { site } from '../helpers';

/** 分组项 */
declare interface ISettingGroupItem extends TitleBarMenuItem {
  /** 副标题 */
  subtitle?: ResourceStr;
}

/** 分组 */
declare interface ISettingGroup {
  /** 分组名 */
  group?: ResourceStr;

  /** 分组内容 */
  items: ISettingGroupItem[];
}

@Builder
export function buildSetting() {
  VSetting()
}

@Component({ freezeWhenInactive: true })
export struct VSetting {
  static readonly padding = 12;
  static readonly margin = 8;
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 是大屏 */
  @Consume('isLarge')
  isLarge: boolean;
  /** 导航菜单 */
  navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.helper"),
      action: () => { }
    }
  ];
  /** 主题模式对话框 */
  themeController: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: $r("app.string.theme_mode"),
      options: [
        {
          contents: [
            {
              title: $r("app.string.system"),
              value: ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
            },
            {
              title: $r("app.string.dark"),
              value: ConfigurationConstant.ColorMode.COLOR_MODE_DARK
            },
            {
              title: $r("app.string.light"),
              value: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
            }
          ],
          selectedIndex: [site.themeMode + 1]
        }
      ],
      onConfirm: (_, items) => site.themeMode = items[0] as number
    }),
    cornerRadius: 16
  });
  /** 设置分组列表 */
  settingGroups: ISettingGroup[] = [
    {
      group: $r("app.string.source"),
      items: [
        {
          value: $r("app.media.img_bed"),
          label: $r("app.string.img_source_manage"),
          subtitle: $r("app.string.img_source_manage_sub"),
          action: () => this.pageStack.pushPathByName(Const.imgSourceManage, null, true)
        },
        {
          value: $r("app.media.img_bed"),
          label: $r("app.string.bed_source_manage"),
          subtitle: $r("app.string.bed_source_manage_sub"),
          action: () => this.pageStack.pushPathByName(Const.bedSourceManage, null, true)
        },
        {
          value: $r("app.media.theme"),
          label: $r("app.string.theme_mode"),
          subtitle: $r("app.string.theme_mode_sub"),
          action: (): void => this.themeController.open()
        }
      ]
    },
    {
      group: $r("app.string.setting"),
      items: [
        {
          value: $r("app.media.folder"),
          label: $r("app.string.backup_setting"),
          subtitle: $r("app.string.backup_setting_sub"),
          action: () => { }
        },
        {
          value: $r("app.media.theme"),
          label: $r("app.string.theme_setting"),
          subtitle: $r("app.string.theme_setting_sub"),
          action: () => { }
        },
        {
          value: $r("app.media.other_setting"),
          label: $r("app.string.other_setting"),
          subtitle: $r("app.string.other_setting_sub"),
          action: () => { }
        }
      ]
    },
    {
      group: $r("app.string.other"),
      items: [
        {
          value: $r("app.media.about"),
          label: $r("app.string.about"),
          action: () => this.pageStack.pushPathByName(Const.about, null, true)
        },
        {
          value: $r("app.media.quit"),
          label: $r("app.string.quit"),
          action: () => (getContext(this) as common.UIAbilityContext).terminateSelf()
        }
      ]
    }
  ];
  /** 页面是否正在进入, 大屏为 true, 小屏则为 false */
  @State
  private _pageEnter: boolean = true;
  private _navDestinationId?: string;
  //
  private _primary: ResourceColor = $r("app.color.primary");
  private _font: ResourceColor = $r('app.color.font');
  private _subtitleText: ResourceColor = $r("app.color.fontSecondary");
  private _buttonNormal: ResourceColor = $r('app.color.button_normal');
  private _iconSize: Length = $r('app.float.icon_size');
  private _textSm: Length = $r('app.float.text_sm');

  aboutToAppear(): void {
    this._pageEnter = this.isLarge;
  }

  build() {
    NavDestination() {
      TitleBar({ title: $r("app.string.setting"), menuItems: this.navMenus })
      List({ space: VSetting.padding }) {
        ForEach(this.settingGroups, (group: ISettingGroup) => {
          ListItemGroup({ header: this.buildHead(group.group), style: ListItemGroupStyle.CARD }) {
            ForEach(group.items, (item: ISettingGroupItem) => {
              ListItem() {
                Button({ type: ButtonType.Normal, buttonStyle: ButtonStyleMode.TEXTUAL }) {
                  Row() {
                    Image(item.value)
                      .borderRadius(999)
                      .fillColor(this._primary)
                      .width(this._iconSize)
                      .height(this._iconSize)
                    Column() {
                      Text(item.label)
                      if (item.subtitle) {
                        Text(item.subtitle)
                          .fontColor(this._subtitleText)
                          .fontSize(this._textSm)
                          .margin({ top: VSetting.margin })
                      }
                    }
                    .margin({ left: VSetting.margin })
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                }
                .fontColor(this._font)
                .padding(VSetting.padding)
                .borderRadius(VSetting.padding)
                .width('100%')
                .onClick(item.action)
              }
              .width('100%')
            })
          }
          .width('100%')
          .borderWidth(0.5)
          .borderColor(this._buttonNormal)
          .shadow({ color: this._buttonNormal, radius: VSetting.padding })
          .backgroundColor(Color.Transparent)
        })
      }
      .width('100%')
      .height('auto')
      .flexGrow(1)
      .flexShrink(1)
      .flexBasis('0%')
      .padding({ top: 12 })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .opacity(this._pageEnter ? 0 : 1)
    .onDisAppear(() => site.unregisterNavTransition(this._navDestinationId!))
    .onReady((ctx) => {
      site.registerNavTransition(this._navDestinationId = ctx.navDestinationId!, {
        onInit: (isExit) => this._pageEnter = !isExit,
        onEnd: (isExit) => this._pageEnter = isExit
      });
    })
  }

  @Builder
  buildHead(group?: ResourceStr) {
    if (group) {
      Text(group)
        .fontColor(this._primary)
        .fontSize(this._textSm)
        .padding({ left: VSetting.padding })
        .margin({ top: 4, bottom: VSetting.margin })
    }
  }
}