import { Columns, ColumnType, Entity } from '@ohos/dataorm';
import { Const, IBaseThemeSource } from '../common';
import { BasicTable } from './Base';

/**
 * 主题源
 */
@Observed
@Entity(Const.tThemeSource)
export class ThemeSource extends BasicTable implements IBaseThemeSource {
  /** 主色调 */
  @Columns({ columnName: 'primary', types: ColumnType.str })
  primary?: string;
  /** 标题栏、导航栏颜色 */
  @Columns({ columnName: 'accent', types: ColumnType.str })
  accent?: string;
  /** 背景色 */
  @Columns({ columnName: 'background', types: ColumnType.str })
  background?: string;
  /** 激活按钮的颜色 */
  @Columns({ columnName: 'buttonActive', types: ColumnType.str })
  buttonActive?: string;
  /** 第一级文本颜色, 默认文本及标题等等 */
  @Columns({ columnName: 'font', types: ColumnType.str })
  font?: string;
  /** 次要文本颜色, 子标题等等 */
  @Columns({ columnName: 'fontSecondary', types: ColumnType.str })
  fontSecondary?: string;
  /** 图标的反转颜色, 用于彩色背景 */
  @Columns({ columnName: 'iconOn', types: ColumnType.str })
  iconOn?: string;
  /** 字体的反转颜色, 用于彩色背景 */
  @Columns({ columnName: 'fontOn', types: ColumnType.str })
  fontOn?: string;
  /** 按钮的分割线颜色 */
  @Columns({ columnName: 'buttonDivider', types: ColumnType.str })
  buttonDivider?: string;
  /** 点击按钮时的喷溅颜色 */
  @Columns({ columnName: 'buttonNormal', types: ColumnType.str })
  buttonNormal?: string;

  constructor(item?: IBaseThemeSource) {
    super(item?.id);
    this.primary = item?.primary;
    this.accent = item?.accent;
    this.background = item?.background;
    this.buttonActive = item?.buttonActive;
    this.font = item?.font;
    this.fontSecondary = item?.fontSecondary;
    this.iconOn = item?.iconOn;
    this.fontOn = item?.fontOn;
    this.buttonDivider = item?.buttonDivider;
    this.buttonNormal = item?.buttonNormal;
  }
}