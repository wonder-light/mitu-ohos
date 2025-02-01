//
// Created on 2025/2/1.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#pragma once

#ifndef MITU_UTILS_H
#define MITU_UTILS_H

#include <ark_runtime/jsvm_types.h>
#include <js_native_api_types.h>
#include <string>

// eval-js
namespace eval
{

// 获取传入的JS代码，转char[]类型
std::string napiValueToString(napi_env env, napi_value nValue);

// 从OH_Value 转为string
std::string fromOHStringValue(JSVM_Env &env, JSVM_Value &value);

} // namespace eval

#endif // MITU_UTILS_H
