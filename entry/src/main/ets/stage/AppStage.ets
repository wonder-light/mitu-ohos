import { AbilityStage } from '@kit.AbilityKit';
import { worker } from '@kit.ArkTS';
import app from '@system.app';

export class AppAbilityStage extends AbilityStage {
  background: worker.ThreadWorker | undefined;

  onCreate(): void {
    // 设置图片文件数据缓存上限为200MB (200MB=200*1024*1024B=209715200B)
    app.setImageFileCacheSize(209715200);
    // 设置内存中缓存解码前图片数据的大小上限100MB (100MB=100*1024*1024B=104857600B)
    app.setImageRawDataCacheSize(104857600);
    // 设置内存中缓存解码后图片的数量上限
    app.setImageCacheCount(200);
    // 设置后台线程
    this.background = new worker.ThreadWorker('entry/ets/workers/background.ets');
  }

  onDestroy(): void {
    this.background?.terminate();
    this.background = undefined;
  }
}