/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 *
 * Based on DaoException.java written by
 * Copyright (C) 2011-2016 Markus Junginger, greenrobot (http://greenrobot.org)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


function isFunction(object: any): boolean {

    if (object == undefined || object == null) {
        return false;
    }
    let typeString = typeof object;
    if (typeString == "function") {
        return true;
    } else {
        return false;
    }
}

/**
 * Exception thrown when something goes wrong in the DAO/ORM layer.
 * 
 * @author Markus
 * 
 */
export class DaoException extends Error {
    constructor(message?: string | Function, cause?: Error) {
        super();
        if (message) {
            this.message = isFunction(message) ? (<Function> message)() : message;
        }
        if (cause) {
            this.safeInitCause(cause);
        }
    }

    protected safeInitCause(cause: Error): void {

    }
}
