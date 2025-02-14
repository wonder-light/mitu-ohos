import { Columns, ColumnType, Entity } from '@ohos/dataorm';
import { IAlbumRule } from '../../common';
import { BasicTable } from '../Base';

/**
 * 相册规则
 */
@Observed
@Entity('AlbumRule')
export class AlbumRule extends BasicTable implements IAlbumRule {
  @Columns({ columnName: 'listRule', types: ColumnType.str })
  listRule: string;
  @Columns({ columnName: 'createRule', types: ColumnType.str })
  createRule: string;
  @Columns({ columnName: 'deleteRule', types: ColumnType.str })
  deleteRule: string;

  constructor(item?: IAlbumRule) {
    super(item?.id);
    this.listRule = item?.listRule ?? '';
    this.createRule = item?.createRule ?? '';
    this.deleteRule = item?.deleteRule ?? '';
  }
}