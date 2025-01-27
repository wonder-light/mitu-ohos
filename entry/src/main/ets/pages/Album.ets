@Component
export struct VAlbum {
  /**
   * 导航栈
   */
  @Consume('pageStack')
  pageStack: NavPathStack;
  @State
  message: string = 'Hello Album';

  build() {
    NavDestination() {
      RelativeContainer() {
        Text(this.message)
          .id('HomeHelloWorld')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.message = 'Welcome';
          })
      }
      .height('100%')
      .width('100%')
    }
    .title('album')
  }
}