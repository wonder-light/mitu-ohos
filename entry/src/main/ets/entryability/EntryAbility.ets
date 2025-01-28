import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import Log from '../helpers/Log';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 创建主窗口，设置此功能的主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Log.d('Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
    });
  }
}