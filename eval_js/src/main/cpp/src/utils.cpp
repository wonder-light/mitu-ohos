#include <js_native_api.h>
#include <ark_runtime/jsvm.h>
#include "utils.h"

// eval-js
namespace eval
{

// 获取传入的JS代码，转char[]类型
std::string napiValueToString(napi_env env, napi_value nValue)
{
    size_t buffLen = 0;
    napi_get_value_string_utf8(env, nValue, nullptr, 0, &buffLen);
    char buffer[buffLen + 1];
    napi_get_value_string_utf8(env, nValue, buffer, buffLen + 1, &buffLen);
    return buffer;
}

// 从OH_Value 转为string
std::string fromOHStringValue(JSVM_Env &env, JSVM_Value &value)
{
    size_t size;
    OH_JSVM_GetValueStringUtf8(env, value, nullptr, 0, &size);
    char resultStr[size + 1];
    OH_JSVM_GetValueStringUtf8(env, value, resultStr, size + 1, &size);
    return resultStr;
}

}