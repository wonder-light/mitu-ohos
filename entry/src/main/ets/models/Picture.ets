import { Entity, ToOne } from '@ohos/dataorm';
import { Const } from '../common';
import { IPictureSource } from '../common/Interface';
import { BaseSource } from './BaseSource';
import { DiscoverRule } from './rule/Discover';
import { SearchRule } from './rule/Search';

/**
 * 图片源
 */
@Observed
@Entity(Const.tPictureSource)
export class PictureSource extends BaseSource implements IPictureSource {
  @ToOne({ joinProperty: 'id', targetObj: SearchRule })
  searchRule: SearchRule;
  /** 发现规则 */
  @ToOne({ joinProperty: 'id', targetObj: DiscoverRule })
  discoverRule: DiscoverRule;

  constructor(item?: IPictureSource) {
    super(item);
    this.searchRule = new SearchRule(item?.searchRule);
    this.discoverRule = new DiscoverRule(item?.discoverRule);
    this.discoverRule.id = this.searchRule.id = this.id;
  }
}