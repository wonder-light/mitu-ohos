import { ImagePreview, ImagePreviewController } from '@rv/image-preview';
import { Const } from '../../common/Constant';
import { TitleBar } from './TitleBar';

@Component
@CustomDialog
export struct ImageDialog {
  /** 弹窗控制器 */
  declare dialogController: CustomDialogController;
  /** 预览控制器 */
  declare controller: ImagePreviewController;
  /** 预览 */
  @State
  isPreview: boolean = true;

  aboutToAppear(): void {
    this.controller.setOnClick(() => this.switchBgColor());
    this.switchBgColor();
  }

  build() {
    Column() {
      Stack() {
        ImagePreview({ controller: this.controller })
        TitleBar({ enableBack: true, bgColor: Const.cBackground, backCall: () => this.dialogController.close() })
          .position({ top: 10, left: 0, right: 0 })
          .visibility(this.isPreview ? Visibility.None : Visibility.Visible)
      }
    }
    .padding({ top: 20, bottom: 20 })
    .backgroundColor(this.isPreview ? Const.cFont : Const.cBackground)
  }

  /** 切换背景色 */
  switchBgColor() {
    animateTo({
      duration: 300,
      curve: Curve.Ease
    }, () => {
      this.isPreview = !this.isPreview;
    })
  }
}