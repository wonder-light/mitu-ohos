import Log from '../helpers/Log';

@Builder
export function HomeBuilder() {
  Home()
}

@Component
struct Home {
  @State message: string = 'Hello World';
  pageInfos: NavPathStack | null = null;

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
    .title('entry-pageOne')
    .onReady((context) => {
      this.pageInfos = context.pathStack;
      Log.i(JSON.stringify(this.pageInfos));
    })
  }
}