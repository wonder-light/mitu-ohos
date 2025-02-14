import { common } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { TitleBar, TitleBarMenuItem } from '../../component';

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

  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.about"), menuItems: this.navMenus })

    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
  }

  /** 分享 */
  share(): void {
    // 获取UIAbility上下文对象
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    let title = context.resourceManager.getStringSync($r("app.string.about_page_share"));
    let data: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.PLAIN_TEXT,
      title: title,
      content: 'https://github.com/wonder-light/mitu-ohos/releases/latest'
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(data);
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE
    });
  }
}