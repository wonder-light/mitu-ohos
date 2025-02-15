/*
  * Copyright (c) 2022 Huawei Device Co., Ltd.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
    *
  * http://www.apache.org/licenses/LICENSE-2.0
    *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

import { AbstractCondition } from './AbstractCondition'
import { StringBuilder } from '../StringBuilder'

export class StringCondition extends AbstractCondition {
    protected str: string;

    public constructor(str: string, value?: any, values?: any[]) {
        super(value, values);
        this.str = str;
    }

    public getStr(): string {
      return this.str;
    }

    public appendTo(builder: StringBuilder, tableAlias: string) {
        builder.append(tableAlias)
    }
}