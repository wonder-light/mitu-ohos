import Log from '../helpers/Log';
import { RouterBuild, Router } from '../router/Index';

@Entry
@Component
struct Index {
  pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Button('app.string.entry_pageTwo', { stateEffect: true, type: ButtonType.Capsule })
        .width('app.string.button_width')
        .height('app.string.button_height')
        .onClick(() => {
          //Push the NavDestination page information specified by name onto the stack, and pass the data as param.
          Log.i(JSON.stringify(this.pageStack));
          this.pageStack.pushPathByName("home", null, false);
        })
    }
    .title('突破')
    .navDestination(RouterBuild)
  }
}