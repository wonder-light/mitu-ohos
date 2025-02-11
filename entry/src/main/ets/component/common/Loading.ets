/**
 * Loading 组件
 */
@ComponentV2
export struct Loading {
  /** 使用自定义加载样式 */
  @Param
  custom: boolean = true;
  /** 加载图片的大小 */
  @Param
  customSize?: Length = 60;
  /** LoadingProgress 的大小 */
  @Param
  progressSize?: Length = 20;

  build() {
    if (this.custom) {
      Image($r('app.media.loading_gif'))
        .width('100%')
        .constraintSize({ maxHeight: this.customSize })
        .objectFit(ImageFit.ScaleDown)
    } else {
      LoadingProgress().width(this.progressSize)
    }
  }
}