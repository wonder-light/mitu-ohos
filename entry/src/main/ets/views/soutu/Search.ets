import { TitleBar } from '../../component/common/TitleBar';

@Builder
export function buildSearch() {
  VSearch();
}

@Component({ freezeWhenInactive: true })
export struct VSearch {
  /** 导航栈 */
  @Consume('pageStack')
  pageStack: NavPathStack;
  /** 搜索值 */
  @State
  changeValue: string = ''
  /** 搜索控制器 */
  private controller: SearchController = new SearchController();

  build() {
    NavDestination() {
      TitleBar({ enableBack: true, title: $r("app.string.soutu") }) {
        Search({ value: this.changeValue, placeholder: $r("app.string.search_placeholder"), controller: this.controller })
          .searchButton('>')
          .onSubmit(() => this.searchPicture())
      }

      Text('dkfjskejflkds')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  /** 搜索图片 */
  searchPicture() {

  }
}