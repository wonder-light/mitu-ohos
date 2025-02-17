import { Columns, ColumnType, Id } from '@ohos/dataorm';
import { IBasicTable } from '../common';

/**
 * 表格基础
 */
@Observed
export class BasicTable implements IBasicTable {
  @Id({ autoincrement: true })
  @Columns({ columnName: 'id', types: ColumnType.num })
  id: number;

  constructor(item?: number) {
    this.id = item ?? Date.now();
  }
}