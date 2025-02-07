import { lang } from '@kit.ArkTS';

export interface ISendable<T> extends lang.ISendable {
  value: T;
}

@Sendable
export class USendable<T> implements ISendable<T> {
  value: T;

  constructor(value: T) {
    this.value = value;
  }
}