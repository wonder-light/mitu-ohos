import { picker } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

/**
 * 媒体实用程序
 */
export class MediaUt {
  /**
   * 从设备中选择一张图片
   * @returns 文件URI
   */
  public static async selectPicture(): Promise<string | undefined> {
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let result = await photoPicker.select();
    return result.photoUris.shift();
  }

  /**
   * 从设备中选择文件
   * @param option 选择选项
   * @returns 文件URI
   */
  public static async selectFile(option?: picker.DocumentSelectOptions): Promise<string | undefined> {
    let context = getContext();
    let documentPicker = new picker.DocumentViewPicker(context);
    let result = await documentPicker.select(option);
    return result.shift();
  }
}

/**
 * 媒体实用程序
 */
export const mediaUt = new MediaUt();