import { Columns, ColumnType, Entity } from '@ohos/dataorm';
import { IImageRule } from '../../common';
import { BasicTable } from '../Base';

/**
 * 图片规则
 */
@Observed
@Entity('ImageRule')
export class ImageRule extends BasicTable implements IImageRule {
  @Columns({ columnName: 'listRule', types: ColumnType.str })
  listRule: string;
  @Columns({ columnName: 'uploadRule', types: ColumnType.str })
  uploadRule: string;
  @Columns({ columnName: 'deleteRule', types: ColumnType.str })
  deleteRule: string;

  constructor(item?: IImageRule) {
    super(item?.id);
    this.listRule = item?.listRule ?? '';
    this.uploadRule = item?.uploadRule ?? '';
    this.deleteRule = item?.deleteRule ?? '';
  }
}