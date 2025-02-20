//
// Created on 2025/2/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#pragma once

#ifndef MITU_OBJECT_H
#define MITU_OBJECT_H

#include <js_native_api.h>

namespace utils
{
namespace object
{
/**
 * 获取对象的键
 */
napi_value Keys(napi_env env, napi_callback_info info);
/**
 * 获取对象的值
 */
napi_value Values(napi_env env, napi_callback_info info);
/**
 * 分配对象属性
 */
napi_value Assign(napi_env env, napi_callback_info info);
/**
 * 深度分配对象属性
 */
napi_value AssignDeep(napi_env env, napi_callback_info info);
/**
 * 创建一个 对象的浅拷贝
 */
napi_value Copy(napi_env env, napi_callback_info info);
/**
 * 创建一个 对象的深拷贝
 */
napi_value Clone(napi_env env, napi_callback_info info);
} // namespace object
} // namespace utils
#endif // MITU_OBJECT_H
