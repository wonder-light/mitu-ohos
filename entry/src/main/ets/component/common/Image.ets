/**
 * 图片组件
 */
@Reusable
@Component
export struct ImageCom {
  /** 源图片 */
  declare src: string;
  /** 加载中显示的图片 */
  load: ResourceStr = $r("app.media.loading_gif");
  /** 加载失败时显示的图片 */
  error: ResourceStr | undefined;
  /**
   * == 0, 加载中
   * < 0, 加载失败
   * > 0, 加载成功
   */
  @State
  isLoading: number = 0;

  build() {
    Image(this.src)
      .width('100%')
      .alt(this.isLoading < 0 ? this.error ?? this.load : this.load)
      .autoResize(true)
      .objectFit(this.isLoading > 0 ? ImageFit.Cover : ImageFit.ScaleDown)
      .copyOption(CopyOptions.LocalDevice)
      .onComplete(() => this.isLoading = 1)
      .onFinish(() => this.isLoading = 1)
      .onError(() => this.isLoading = -1)
      .hitTestBehavior(HitTestMode.None)
  }
}