import { ImagePreview, ImagePreviewController } from '@rv/image-preview';
import { TitleBar } from './TitleBar';

@CustomDialog
export struct ImageDialog {
  /** 弹窗控制器 */
  declare dialogController: CustomDialogController;
  /** 预览控制器 */
  declare controller: ImagePreviewController;
  /** 预览 */
  @State
  isPreview: boolean = true;
  /** 预览背景色 */
  private _bgColor1: ResourceColor = $r('app.color.font');
  private _bgColor2: ResourceColor = $r('app.color.background');

  aboutToAppear(): void {
    this.controller.setOnClick(() => this.switchBgColor());
    this.switchBgColor();
  }

  build() {
    Column() {
      Stack() {
        ImagePreview({ controller: this.controller })
        TitleBar({ enableBack: true, bgColor: this._bgColor2, backCall: () => this.dialogController.close() })
          .position({ top: 10, left: 0, right: 0 })
          .visibility(this.isPreview ? Visibility.None : Visibility.Visible)
      }
    }
    .padding({ top: 20, bottom: 20 })
    .backgroundColor(this.isPreview ? this._bgColor1 : this._bgColor2)
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