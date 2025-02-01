//
// Created on 2025/2/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#pragma once

#ifndef MITU_JSVM_H
#define MITU_JSVM_H

#include <js_native_api.h>
#include <js_native_api_types.h>
#include "utils.h"

// eval-js
namespace eval
{

// 创建 jsvm 虚拟机 通过 napi 调用
void CreateJsContext();

// 释放先前创建的各种scope 关闭vm napi调用
void DisposeResources(int id);

// 提供创建JSVM运行环境的对外接口并返回对应唯一ID
napi_value CreateJsCore(napi_env env, napi_callback_info info);

// 对外提供执行 JS 代码接口，通过 coreID 在对应的 jsvm 环境中执行 JS 代码
napi_value EvalJS(napi_env env, napi_callback_info info);

// 对外提供释放JSVM环境接口，通过envId释放对应环境
napi_value DisposeJsCore(napi_env env, napi_callback_info info);

} // namespace eval
#endif // MITU_JSVM_H
