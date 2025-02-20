//
// Created on 2025/2/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "thread.h"
#include <hilog/log.h>

namespace utils
{
namespace thread
{

/**
 * Promise 完成时的回调函数
 * @param env
 * @param info
 * @return
 */
napi_value ResolvedCallback(napi_env env, napi_callback_info info)
{
    // 在 ExecuteWork 中执行 napi_call_threadsafe_function 时传递的第二个参数
    CallbackData *data = nullptr;
    size_t argc = 1;
    napi_value argv[1];
    if (napi_get_cb_info(env, info, &argc, argv, nullptr, reinterpret_cast<void **>(&data)) != napi_ok)
    {
        return nullptr;
    }
    // 接受
    napi_resolve_deferred(env, data->result, argv[0]);
    // 完成等待
    data->promise->set_value(true);
    return nullptr;
}

/**
 * Promise 拒绝时的回调函数
 * @param env
 * @param info
 * @return
 */
napi_value RejectedCallback(napi_env env, napi_callback_info info)
{
    // 在 ExecuteWork 中执行 napi_call_threadsafe_function 时传递的第二个参数
    CallbackData *data = nullptr;
    size_t argc = 1;
    napi_value argv[1];
    if (napi_get_cb_info(env, info, &argc, argv, nullptr, reinterpret_cast<void **>(&data)) != napi_ok)
    {
        return nullptr;
    }
    // 拒绝
    napi_reject_deferred(env, data->result, argv[0]);
    // 完成等待
    data->promise->set_value(false);
    return nullptr;
}

/**
 * 在主线程中调用 ResolvedCallback 和 RejectedCallback
 * @param env
 * @param jsCallback 在 StartThread 中执行 napi_create_threadsafe_function 时传递的倒数第二个参数
 * @param context 在 StartThread 中执行 napi_create_threadsafe_function 时传递的倒数第三个参数
 * @param data 在 ExecuteWork 中执行 napi_call_threadsafe_function 时传递的第二个参数
 */
void CallJs(napi_env env, napi_value jsCallback, void *context, void *data)
{
    if (env == nullptr) return;
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(context);
    // 结果
    napi_value promise = nullptr;
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);
    // 获取引用值
    napi_value args;
    napi_get_reference_value(env, callbackData->args, &args);
    // 调用 js 函数
    napi_call_function(env, undefined, jsCallback, callbackData->argc, &args, &promise);
    // then 函数
    napi_value thenFunc = nullptr;
    // 判断是否为 promise
    bool isPromise;
    napi_is_promise(env, promise, &isPromise);
    if (!isPromise)
    {
        napi_resolve_deferred(env, callbackData->result, promise);
        // 等待完成
        callbackData->promise->set_value(true);
        return;
    }
    else
    {
        napi_get_named_property(env, promise, "then", &thenFunc);
    }
    napi_value resolvedCallback;
    napi_value rejectedCallback;
    napi_create_function(env, "resolvedCallback", NAPI_AUTO_LENGTH, ResolvedCallback, data, &resolvedCallback);
    napi_create_function(env, "rejectedCallback", NAPI_AUTO_LENGTH, RejectedCallback, data, &rejectedCallback);
    napi_value argv[2] = {resolvedCallback, rejectedCallback};
    napi_call_function(env, promise, thenFunc, 2, argv, nullptr);
}

/**
 * 在工作线程中调用 ExecuteWork，并执行线程安全函数
 * @param env
 * @param data
 */
void ExecuteWork(napi_env env, void *data)
{
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    // 创建 promise
    callbackData->promise = new std::promise<bool>();
    // 调用线程函数
    napi_call_threadsafe_function(callbackData->threadFun, callbackData, napi_tsfn_nonblocking);
    try
    {
        // 等待完成
        auto future = callbackData->promise->get_future();
        future.wait();
        //  OH_LOG_INFO(LOG_APP, "XXX, Result from JS %{public}s", result.c_str());
    }
    catch (const std::exception &e)
    {
        // OH_LOG_INFO(LOG_APP, "XXX, Result from JS %{public}s", e.what());
    }
}

/**
 * 任务执行完成后，进行资源清理回收
 * @param env
 * @param status
 * @param data
 */
void WorkComplete(napi_env env, napi_status status, void *data)
{
    // OH_LOG_INFO(LOG_APP, "WorkComplete %{public}s", "WorkComplete");
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    // 释放线程安全函数
    napi_release_threadsafe_function(callbackData->threadFun, napi_tsfn_release);
    // 释放异步任务
    napi_delete_async_work(env, callbackData->work);
    // 释放数据
    napi_delete_reference(env, callbackData->args);
    callbackData->threadFun = nullptr;
    callbackData->work = nullptr;
    callbackData->args = nullptr;
    callbackData->result = nullptr;
    delete callbackData->promise;
    delete callbackData;
}

napi_value StartThread(napi_env env, napi_callback_info info)
{
    // 可在线程退出时释放;
    CallbackData *callbackData = new utils::thread::CallbackData();
    // 获取所有参数: jsCallback, ...params
    size_t argc = 1;
    napi_get_cb_info(env, info, &argc, nullptr, nullptr, nullptr);
    napi_value *args = new napi_value[argc]{nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value jaCallback = args[0];
    // 保存参数
    args++;
    callbackData->argc = argc - 1;
    napi_create_reference(env, *args, 1, &callbackData->args);
    // 创建 promise
    napi_deferred deferred;
    napi_value promise;
    napi_create_promise(env, &deferred, &promise);
    callbackData->result = deferred;
    // 创建一个线程安全函数
    napi_value workName = nullptr;
    napi_create_string_utf8(env, "Thread-Safe Function", NAPI_AUTO_LENGTH, &workName);
    napi_create_threadsafe_function(env, jaCallback, nullptr, workName, 0, 1, callbackData, nullptr, callbackData, CallJs, &callbackData->threadFun);
    // 创建一个异步任务
    // ExecuteWork会执行在一个由libuv创建的非JS线程上，此处使用napi_create_async_work是为了模拟在非JS线程场景使用napi_call_threadsafe_function接口向JS线程提交任务
    napi_create_async_work(env, nullptr, workName, ExecuteWork, WorkComplete, callbackData, &callbackData->work);
    // 将异步任务加入到异步队列中
    napi_queue_async_work(env, callbackData->work);
    // 释放参数
    --args;
    delete[] args;
    // 返回 promise
    return promise;
}

} // namespace thread
}