import { IDiscoverItemRule } from "../../common";

/**
 * 图源发现项规则
 */
@Observed
export class DiscoverItemRule implements IDiscoverItemRule {
  name: string;
  urlRule?: string;
  order: number;

  constructor(item?: IDiscoverItemRule) {
    this.name = item?.name ?? '';
    this.urlRule = item?.urlRule;
    this.order = item?.order ?? 0;
  }
}