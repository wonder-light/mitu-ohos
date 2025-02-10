import { lang } from '@kit.ArkTS';

@Sendable
export class USendable<T> implements lang.ISendable {
  value: T;

  constructor(value: T) {
    this.value = value;
  }
}