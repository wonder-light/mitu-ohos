import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { updateManager } from '@kit.StoreKit';
import { Const } from '../../common';
import { IListGroup, ListGroup, TitleBar, TitleBarMenuItem } from '../../component';
import { site } from '../../helpers';
import { Log } from '../../utils';

@Builder
export function buildAbout() {
  VAbout();
}

/** 关于页面 */
@Component
export struct VAbout {
  /** 导航菜单 */
  navMenus: TitleBarMenuItem[] = [
    {
      value: $r("app.media.share"),
      action: () => this.share()
    }
  ];
  /** UIAbility上下文对象 */
  declare ctx: common.UIAbilityContext;
  /** 分组列表 */
  groups: IListGroup[] = [
    {
      items: [
        {
          builder: () => { this.buildHeader() }
        },
        {
          label: $r("app.string.developer"),
          subtitle: $r("app.string.developer_sub"),
          action: () => this.openBrowser()
        },
        {
          label: $r("app.string.update_log"),
          subtitle: $r("app.string.version_param", site.versionName)
        },
        {
          label: $r("app.string.check_update"),
          action: () => this.checkUpdate()
        }
      ]
    }
  ];

  aboutToAppear(): void {
    this.ctx = getContext(this) as common.UIAbilityContext;
  }

  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.about"), menuItems: this.navMenus })
      ListGroup({ groups: this.groups }).margin({ top: Const.fPadding3 })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor(Const.cBackground)
  }

  @Builder
  buildHeader() {
    Column() {
      Text($r('app.string.app_name'))
        .fontSize(Const.fTextXl)
      Text($r('app.string.app_description'))
        .fontSize(Const.fTextSm)
        .fontColor(Const.cFontSecondary)
        .margin({ top: Const.fPadding2 })
    }
    .alignItems(HorizontalAlign.Center)
    .padding(Const.fPadding3)
  }

  /** 分享 */
  share(): void {
    let title = this.ctx.resourceManager.getStringSync($r("app.string.about_page_share"));
    let data: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      title: title,
      content: 'https://github.com/wonder-light/mitu-ohos/releases/latest'
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(data);
    controller.show(this.ctx, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE
    });
  }

  /** 打开浏览器 */
  openBrowser(): void {
    const url = 'https://github.com/wonder-light/mitu-ohos';
    // this.ctx.openLink(url);
    this.ctx.startAbility({
      action: "ohos.want.action.viewData",
      entities: ["entity.system.browsable"],
      uri: url
    })
  }

  /** 检查更新 */
  async checkUpdate(): Promise<void> {
    try {
      let result = await updateManager.checkAppUpdate(this.ctx);
      if (result.updateAvailable == updateManager.UpdateAvailableCode.LATER_VERSION_EXIST) {
        await updateManager.checkAppUpdate(this.ctx);
      }
    } catch (e) {
      Log.e(`checkUpdate error: ${e}`)
    }
  }
}