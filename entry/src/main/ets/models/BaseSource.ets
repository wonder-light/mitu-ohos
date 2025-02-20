import { Columns, ColumnType, Convert, Index } from '@ohos/dataorm';
import { IBaseSource } from '../common';
import { BoolConverter } from '../utils';
import { BasicTable } from './Base';

/**
 * 基础源
 */
@Observed
export class BaseSource extends BasicTable implements IBaseSource {
  @Index()
  @Columns({ columnName: 'origin', types: ColumnType.str })
  origin: string = '';
  @Columns({ columnName: 'originName', types: ColumnType.str })
  originName: string = '';
  @Columns({ columnName: 'name', types: ColumnType.str })
  name: string;
  @Columns({ columnName: 'author', types: ColumnType.str })
  author: string;
  @Columns({ columnName: 'intro', types: ColumnType.str })
  intro: string;
  @Index()
  @Columns({ columnName: 'groups', types: ColumnType.str })
  group: string;
  @Columns({ columnName: 'time', types: ColumnType.num })
  time: number;
  @Columns({ columnName: 'variable', types: ColumnType.str })
  variable: string;
  @Columns({ columnName: 'variableComment', types: ColumnType.str })
  variableComment: string;
  @Columns({ columnName: 'jsLib', types: ColumnType.str })
  jsLib: string;
  @Columns({ columnName: 'orders', types: ColumnType.num })
  order: number;
  @Columns({ columnName: 'isTop', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: BoolConverter })
  isTop: boolean;
  @Columns({ columnName: 'isHide', types: ColumnType.str })
  @Convert({ columnType: ColumnType.str, converter: BoolConverter })
  isHide: boolean;
  @Columns({ columnName: 'respondTime', types: ColumnType.num })
  respondTime: number;
  @Columns({ columnName: 'enabledCookie', types: ColumnType.real })
  enabledCookie: boolean;
  @Columns({ columnName: 'cookieJar', types: ColumnType.real })
  cookieJar: string;
  @Columns({ columnName: 'concurrentRate', types: ColumnType.str })
  concurrentRate: string;
  @Columns({ columnName: 'header', types: ColumnType.str })
  header: string;
  @Columns({ columnName: 'decodeJs', types: ColumnType.str })
  decodeJs: string;
  @Columns({ columnName: 'style', types: ColumnType.str })
  style: string;
  @Columns({ columnName: 'loginUrl', types: ColumnType.str })
  loginUrl: string;
  @Columns({ columnName: 'loginUi', types: ColumnType.str })
  loginUi: string;
  @Columns({ columnName: 'loginCheckJs', types: ColumnType.str })
  loginCheckJs: string;

  constructor(item?: IBaseSource) {
    super(item?.id);
    this.origin = item?.origin ?? '';
    this.originName = item?.originName ?? '';
    this.name = item?.name ?? '';
    this.author = item?.author ?? '';
    this.intro = item?.intro ?? '';
    this.group = item?.group ?? '';
    this.time = item?.time ?? Date.now();
    this.variable = item?.variable ?? '';
    this.variableComment = item?.variableComment ?? '';
    this.jsLib = item?.jsLib ?? '';
    this.order = item?.order ?? 0;
    this.isTop = item?.isTop ?? false;
    this.isHide = item?.isHide ?? false;
    this.respondTime = item?.respondTime ?? -1;
    this.enabledCookie = item?.enabledCookie ?? true;
    this.cookieJar = item?.cookieJar ?? '';
    this.concurrentRate = item?.concurrentRate ?? '';
    this.header = item?.header ?? '';
    this.decodeJs = item?.decodeJs ?? '';
    this.style = item?.style ?? '';
    this.loginUrl = item?.loginUrl ?? '';
    this.loginUi = item?.loginUi ?? '';
    this.loginCheckJs = item?.loginCheckJs ?? '';
  }
}