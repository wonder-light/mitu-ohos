import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { Const } from '../common';
import { site } from '../helpers';
import { Log } from '../utils';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    site.context = this.context;
    this.context.getApplicationContext().setColorMode(site.themeMode);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 判断 site.db 是否已经初始化
    if (!site.db) {
      return emitter.once(Const.siteInit, () => this.onWindowStageCreate(windowStage));
    }
    // 创建主窗口，设置此功能的主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Log.d('Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
    });
  }
}