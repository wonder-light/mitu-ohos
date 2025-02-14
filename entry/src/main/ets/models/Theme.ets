import { CustomTheme, CustomColors, ThemeControl } from '@kit.ArkUI';

// 自定义主题颜色
class LightTheme implements CustomColors {
  fontPrimary = Color.White;
  fontSecondary = Color.White;
  backgroundPrimary = Color.Blue;
  brand = Color.Blue; //品牌色
}

declare interface Theme {
  /** 背景色 */
  background?: ResourceColor;
  /** 第一级文本颜色, 默认文本及标题等等 */
  font?: ResourceColor;
  /** 次要文本颜色, 子标题等等 */
  fontSecondary?: ResourceColor;
}