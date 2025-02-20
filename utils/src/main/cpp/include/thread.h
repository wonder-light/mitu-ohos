//
// Created on 2025/2/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#pragma once


#ifndef MITU_THREAD_H
#define MITU_THREAD_H

#include "napi/native_api.h"
#include <future>

namespace utils
{
namespace thread
{

/**
 * 线程回调数据
 */
typedef struct
{
    /** 线程函数 */
    napi_threadsafe_function threadFun;
    /** 异步 work */
    napi_async_work work;
    /** 参数数量 */
    size_t argc;
    /** 所有参数 */
    napi_ref args;
    /** 函数调用结果 */
    napi_deferred result;
    /** 线程回调结果 */
    std::promise<bool>* promise;
} CallbackData;

/**
 * 启动一个线程
 */
napi_value StartThread(napi_env env, napi_callback_info info);

} // namespace thread
} // namespace utils
#endif // MITU_THREAD_H
