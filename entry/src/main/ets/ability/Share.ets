import { AbilityConstant, ShareExtensionAbility, UIExtensionContentSession, Want } from '@kit.AbilityKit';
import { Log } from '../utils/Log';

const TAG: string = "[ShareExtAbility]";

/**
 * 共享扩展能力
 */
export class ShareExtAbility extends ShareExtensionAbility {
  onCreate(launchParam: AbilityConstant.LaunchParam): void {
    Log.setPrefix('ShareExtAbility');
    Log.d(`onCreate launchParam: ${JSON.stringify(launchParam)}`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    Log.setPrefix('ShareExtAbility');
    Log.d(`onSessionCreate session: ${typeof session}, want: ${JSON.stringify(want)}`);
    if (want.parameters) {
      let obj: Record<string, UIExtensionContentSession | object> = {
        'session': session,
        'messages': want.parameters.shareMessages
      }
      let storage: LocalStorage = new LocalStorage(obj);
      session.loadContent('pages/Index', storage);
    }
  }
}