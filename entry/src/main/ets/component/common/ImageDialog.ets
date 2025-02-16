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
          .position({ top: Const.fPadding2, left: 0, right: 0 })
          .visibility(this.isPreview ? Visibility.None : Visibility.Visible)
      }
    }
    .safeAreaPadding({ top: Const.fPadding3 * 2, bottom: Const.fPadding2 })
    .backgroundColor(this.isPreview ? Const.cFont : Const.cBackground)
  }

  /** 切换背景色 */
  switchBgColor() {
    animateTo(Const.animate3, () => this.isPreview = !this.isPreview)
  }
}