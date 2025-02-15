import { TCustomBuilder } from '../../common';

/**
 * 自定义构建组件
 */
@ComponentV2
export struct CustomItem {
  /** 构建器 */
  @BuilderParam
  builder?: TCustomBuilder;
  /** 构建参数 */
  @Param
  params: Object[] = [];

  build() {
    if (this.builder instanceof Function) {
      this.builder(...this.params)
    } else if (this.builder !== undefined) {
      this.builder
    }
  }
}