import { Entity, ToOne } from '@ohos/dataorm';
import { Const, IBedSource } from '../common';
import { BaseSource } from './BaseSource';
import { AlbumRule } from './rule/Album';
import { ImageRule } from './rule/Image';

/**
 * 图床源
 */
@Observed
@Entity(Const.tBedSource)
export class BedSource extends BaseSource implements IBedSource {
  @ToOne({ joinProperty: 'id', targetObj: AlbumRule })
  albumRule: AlbumRule;
  @ToOne({ joinProperty: 'id', targetObj: ImageRule })
  imageRule: ImageRule;

  constructor(item?: IBedSource) {
    super(item);
    this.albumRule = new AlbumRule(item?.albumRule);
    this.imageRule = new ImageRule(item?.imageRule);
    this.albumRule.id = this.albumRule.id = this.id;
  }
}