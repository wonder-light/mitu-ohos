#include "jsvm.h"
#include <ark_runtime/jsvm.h>
#include <cstdlib>
#include <cstring>
#include <hilog/log.h>
#include <map>
#include <string>

// eval-js
namespace eval
{

// 定义map管理每个独立vm环境
std::map<int, JSVM_VM *> js_vms;
std::map<int, JSVM_Env *> js_envs;
std::map<int, JSVM_VMScope *> js_vm_scopes;
std::map<int, JSVM_EnvScope *> js_env_scopes;
std::map<int, JSVM_CallbackStruct *> js_vm_callbacks;

int js_vm_id = 0;

// 参考 https://cloud.tencent.com/developer/article/2472233

// 创建 jsvm 虚拟机 通过 napi 调用
void CreateJsContext()
{
    JSVM_Status status;
    if (js_vm_id == 0)
    {
        // 初始化 可以设置 vm 启动参数 argv argc
        JSVM_InitOptions init_options;
        memset(&init_options, 0, sizeof(init_options));
        OH_JSVM_Init(&init_options);
    }

    // 虚拟机实例
    JSVM_VM *vm = js_vms[js_vm_id] = new JSVM_VM;
    JSVM_VMScope *vm_scope = js_vm_scopes[js_vm_id] = new JSVM_VMScope;
    // 可以设置 gc 相关参数、snapshot bin 等
    JSVM_CreateVMOptions options;
    memset(&options, 0, sizeof(options));
    // 创建JSVM实例
    status = OH_JSVM_CreateVM(&options, vm);
    // vm scope。在 jsvm 中 scope 即作用域，用于资源管理，在 scope 打开期间资源可用，scope 关闭后自愿释放（RAII）
    // 类似 v8 中各种 scope 的设计，在后续使用中，各种 scope 可以以 raii 风格封装方便使用
    status = OH_JSVM_OpenVMScope(*vm, vm_scope);
    // js env
    JSVM_Env *env = js_envs[js_vm_id] = new JSVM_Env;
    JSVM_EnvScope *env_scope = js_env_scopes[js_vm_id] = new JSVM_EnvScope;
    JSVM_CallbackStruct *callbacks = callbacks = new JSVM_CallbackStruct[5];
    // 注册用户提供的本地函数的回调函数指针和数据，通过JSVM-API暴露给JS
    for (int i = 0; i < 5; i++)
    {
        callbacks[i].data = nullptr;
    }
    /*callbacks[0].callback = Consoleinfo;
    callbacks[1].callback = Add;
    callbacks[2].callback = AssertEqual;
    callbacks[3].callback = OnJSResultCallback;
    callbacks[4].callback = CreatePromise;*/

    //****4****将本地函数的回调函数放到JSVM_PropertyDescriptor集合中
    JSVM_PropertyDescriptor descriptors[] = {
        {"consoleinfo", NULL, &callbacks[0], NULL, NULL, NULL, JSVM_DEFAULT},   {"add", NULL, &callbacks[1], NULL, NULL, NULL, JSVM_DEFAULT},
        {"assertEqual", NULL, &callbacks[2], NULL, NULL, NULL, JSVM_DEFAULT},   {"onJSResultCallback", NULL, &callbacks[3], NULL, NULL, NULL, JSVM_DEFAULT},
        {"createPromise", NULL, &callbacks[4], NULL, NULL, NULL, JSVM_DEFAULT},
    };
    // 创建JSVM环境
    status = OH_JSVM_CreateEnv(*vm, sizeof(descriptors) / sizeof(descriptors[0]), descriptors, env);
    // 创建JSVM环境作用域
    status = OH_JSVM_OpenEnvScope(*env, env_scope);
    js_vm_id++;
}

// 释放先前创建的各种scope 关闭vm napi调用
void DisposeResources(int id)
{
    if (js_vms[id] == nullptr) return;
    JSVM_VM *js_vm = js_vms[id];
    JSVM_Env *js_env = js_envs[id];
    JSVM_VMScope *js_vm_scope = js_vm_scopes[id];
    JSVM_EnvScope *js_env_scope = js_env_scopes[id];
    // 关闭指定的Env的环境作用域
    OH_JSVM_CloseEnvScope(*js_env, *js_env_scope);
    // 销毁指定Env环境
    OH_JSVM_DestroyEnv(*js_env);
    // 关闭指定的VM的作用域
    OH_JSVM_CloseVMScope(*js_vm, *js_vm_scope);
    // 销毁指定VM实例
    OH_JSVM_DestroyVM(*js_vm);
    // 从 map 中删除
    js_vms.erase(id);
    js_envs.erase(id);
    js_vm_scopes.erase(id);
    js_env_scopes.erase(id);
    // 删除回调
    delete[] js_vm_callbacks[id];
    js_vm_callbacks.erase(id);
}

// 提供创建JSVM运行环境的对外接口并返回对应唯一ID
napi_value CreateJsCore(napi_env env, napi_callback_info info)
{
    OH_LOG_DEBUG(LOG_APP, "JSVM CreateJsCore START");
    // 参数
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (argc > 0)
    {
        /*OH_LOG_DEBUG(LOG_APP, "JSVM CreateJsCore add once callback");
        // 将TS侧传入的回调函数与env对应存储方便后续调用
        // napi_ref生命周期由开发者自己管理，需要手动delete，引用 napi_value 的抽象。这允许用户管理 JavaScript 值的生命周期，包括明确定义它们的最小生命周期。
        napi_ref callFun;
        // 为 function 创建一个reference，以延长其生命周期。调用者需要自己管理reference生命周期
        napi_create_reference(env, args[0], 1, &callFun);
        */
    }
    // id
    napi_value coreID = 0;
    eval::CreateJsContext();
    // 累加
    napi_create_uint32(env, js_vm_id - 1, &coreID);
    OH_LOG_DEBUG(LOG_APP, "JSVM CreateJsCore End");
    return coreID;
}

// 对外提供执行 JS 代码接口，通过 coreID 在对应的 jsvm 环境中执行 JS 代码
napi_value EvalJS(napi_env env, napi_callback_info info)
{
    OH_LOG_DEBUG(LOG_APP, "JSVM EvalJS START");
    // 参数数量
    size_t argc = 2;
    // 参数
    napi_value args[2] = {nullptr};
    // 获取参数
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    uint32_t envId = 0;
    napi_status status;
    if (argc < 1)
    {
        return nullptr;
    }
    else if (argc > 1)
    {
        status = napi_get_value_uint32(env, args[0], &envId);
        if (status != napi_ok)
        {
            OH_LOG_WARN(LOG_APP, "EvalJS first param should be number");
            return nullptr;
        }
    }
    if (js_envs.count(envId) == 0 || js_envs[envId] == nullptr)
    {
        OH_LOG_WARN(LOG_APP, "EvalJS env is null");
        return nullptr;
    }
    // 获取传入的JS代码，转char[]类型
    std::string dataStr = napiValueToString(env, args[1]);
    JSVM_Env js_env = *js_envs[envId];
    // scope 用于资源管理
    JSVM_HandleScope handle_scope;
    // 开启新作用域
    OH_JSVM_OpenHandleScope(js_env, &handle_scope);
    // 转为jsvm字符串
    JSVM_Value js_value;
    OH_JSVM_CreateStringUtf8(js_env, dataStr.c_str(), dataStr.size(), &js_value);
    // 编译js脚本
    JSVM_Script js_script;
    OH_JSVM_CompileScript(js_env, js_value, nullptr, 0, true, nullptr, &js_script);
    // 运行脚本
    OH_JSVM_RunScript(js_env, js_script, &js_value);
    JSVM_ValueType type;
    napi_value result = nullptr;
    // 调用typeof运算符的行为,得到结果类型
    OH_JSVM_Typeof(js_env, js_value, &type);
    OH_LOG_INFO(LOG_APP, "JSVM API TEST type: %{public}d", type);
    switch (type)
    {
    case JSVM_UNDEFINED:
        break;
    case JSVM_NULL:
        break;
    case JSVM_BOOLEAN:
        {
            bool ret = false;
            std::string stdResult;
            OH_JSVM_GetValueBool(js_env, js_value, &ret);
            ret ? stdResult = "true" : stdResult = "false";
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &result);
            break;
        }
    case JSVM_NUMBER:
        {
            int32_t num;
            OH_JSVM_GetValueInt32(js_env, js_value, &num);
            std::string stdResult = std::to_string(num);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &result);
            break;
        }
    case JSVM_STRING:
        {
            // JSVM_Value转字符串
            std::string stdResult = eval::fromOHStringValue(js_env, js_value);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &result);
            break;
        }
    case JSVM_SYMBOL:
        break;
    case JSVM_OBJECT:
        {
            JSVM_Value objResult;
            OH_JSVM_JsonStringify(js_env, js_value, &objResult);
            std::string stdResult = eval::fromOHStringValue(js_env, objResult);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &result);
            break;
        }
    case JSVM_FUNCTION:
        break;
    case JSVM_EXTERNAL:
        break;
    case JSVM_BIGINT:
        break;
    }
    // 关闭传入的作用域
    OH_JSVM_CloseHandleScope(js_env, handle_scope);
    // 释放脚本
    OH_JSVM_ReleaseScript(js_env, js_script);
    OH_LOG_DEBUG(LOG_APP, "JSVM EvalJS END");
    return result;
}

// 对外提供释放JSVM环境接口，通过envId释放对应环境
napi_value DisposeJsCore(napi_env env, napi_callback_info info)
{
    OH_LOG_DEBUG(LOG_APP, "JSVM DisposeJsCore START");
    // 参数
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // id
    uint32_t coreEnvId = 0;
    if (argc >= 1)
    {
        napi_status status = napi_get_value_uint32(env, args[0], &coreEnvId);
        if (status != napi_ok)
        {
            OH_LOG_WARN(LOG_APP, "JSVM CreateJsCore napi_get_value_uint32 faild");
            return nullptr;
        }
    }
    // 是否存在创建的env环境
    if (js_envs.count(coreEnvId) == 0 || js_envs[coreEnvId] == nullptr)
    {
        OH_LOG_WARN(LOG_APP, "JSVM CreateJsCore not has env ");
        return nullptr;
    }

    // 关闭指定的Env的环境作用域
    eval::DisposeResources(coreEnvId);
    OH_LOG_DEBUG(LOG_APP, "JSVM DisposeJsCore END");
    return nullptr;
}

}
