import { Columns, ColumnType, Id } from '@ohos/dataorm';
import { ITableBasic } from '../common';

/**
 * 表格基础
 */
@Observed
export class TableBasic implements ITableBasic {
  @Id()
  @Columns({ columnName: 'id', types: ColumnType.num })
  id: number;

  constructor(item?: number) {
    this.id = item ?? 0;
  }
}