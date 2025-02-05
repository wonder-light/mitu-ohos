import { ISearchResultItem } from '../common/Interface';

/**
 * 搜索结果项, 搜索结果的最小单位
 */
@Observed
export class SearchResultItem implements ISearchResultItem {
  /** 略缩图 URL */
  thumbnail?: string;
  /** 原始图 URL */
  origin: string = '';
  /** 名称 */
  name?: string;
  /** 作者 */
  author?: string;
  /** 简介 */
  intro?: string;
  /** 分类 */
  kind?: string[];

  constructor(item?: ISearchResultItem) {
    this.thumbnail = item?.thumbnail;
    this.origin = item?.origin ?? '';
    this.name = item?.name;
    this.author = item?.author;
    this.intro = item?.intro;
    this.kind = item?.kind;
  }
}