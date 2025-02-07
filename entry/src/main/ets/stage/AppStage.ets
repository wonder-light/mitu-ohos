import { AbilityStage } from '@kit.AbilityKit';
import { sendablePreferences } from '@kit.ArkData';
import { worker } from '@kit.ArkTS';
import app from '@system.app';
import { site } from '../helpers';

export class AppAbilityStage extends AbilityStage {
  onCreate(): void {
    // 设置图片文件数据缓存上限为200MB (200MB=200*1024*1024B=209715200B)
    app.setImageFileCacheSize(209715200);
    // 设置内存中缓存解码前图片数据的大小上限100MB (100MB=100*1024*1024B=104857600B)
    app.setImageRawDataCacheSize(104857600);
    // 设置内存中缓存解码后图片的数量上限
    app.setImageCacheCount(200);
    // 设置后台线程
    site.background = new worker.ThreadWorker('entry/ets/workers/background.ets');
    // com.nianian.mitu
    site.bundleName = this.context.applicationInfo.name;
    // mitu
    const name = site.bundleName.split('.').pop()!;
    // 首选项
    site.pf = sendablePreferences.getPreferencesSync(this.context, { name: name });
    //site.kv = DataKvUtil.getInstance().init(this.context, site.bundleName);
    // 初始化站点数据
    site.initialize(this.context);
  }

  onDestroy(): void {
    site.background.terminate();
  }
}