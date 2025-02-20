//
// Created on 2025/2/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".


#include "object.h"

namespace utils
{
namespace object
{
/**
 * 获取对象的键
 */
napi_value _GetKeys(napi_env env, napi_value Obj)
{
    // 默认对象
    static napi_value defaultObj = nullptr;
    // 获取key
    napi_value keys;
    napi_get_all_property_names(env, Obj, napi_key_collection_mode::napi_key_include_prototypes, napi_key_filter::napi_key_skip_symbols,
                                napi_key_conversion::napi_key_keep_numbers, &keys);
    // 存储新的 keys
    napi_value values;
    napi_create_array(env, &values);
    // 判断是否是数组
    bool isTrue;
    napi_is_array(env, keys, &isTrue);
    if (!isTrue) return values;
    // 创建默认对象
    if (defaultObj == nullptr)
    {
        napi_create_object(env, &defaultObj);
    }
    // 获取 key 的长度
    uint32_t length;
    napi_get_array_length(env, keys, &length);
    for (int i = 0, j = 0; i < length; i++)
    {
        // 获取请求索引位置的元素值并存储在result中
        napi_value key;
        napi_get_element(env, keys, i, &key);
        // 判断是否已经在默认对象中存在
        napi_has_property(env, defaultObj, key, &isTrue);
        if (!isTrue)
        {
            // 设置 index 位置的元素值为 key 对应的值
            napi_set_element(env, values, j, key);
            j++;
        }
    }
    return values;
}

/**
 * 分配对象属性
 */
void _Assign(napi_env &env, napi_value &target, napi_value &source, bool isDeep = false)
{
    napi_value keys = _GetKeys(env, source);
    // 获取 key 的长度
    uint32_t length;
    napi_get_array_length(env, keys, &length);
    for (int i = 0; i < length; i++)
    {
        // 获取请求索引位置的元素值并存储在result中
        napi_value key;
        napi_get_element(env, keys, i, &key);
        // 获取 key 对应的值
        napi_value value;
        napi_get_property(env, source, key, &value);
        if (isDeep)
        {
            // 判断是否是对象
            napi_valuetype valuetype;
            napi_typeof(env, value, &valuetype);
            if (valuetype == napi_object)
            {
                napi_value obj;
                napi_create_object(env, &obj);
                _Assign(env, obj, value, isDeep);
                value = obj;
            }
        }
        // 设置 index 位置的元素值为 key 对应的值
        napi_set_property(env, target, key, value);
    }
}

napi_value Keys(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    return _GetKeys(env, args[0]);
}

napi_value Values(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value values = _GetKeys(env, args[0]);
    // 获取 key 的长度
    uint32_t length;
    napi_get_array_length(env, values, &length);
    for (int i = 0; i < length; i++)
    {
        // 获取请求索引位置的元素值并存储在result中
        napi_value key;
        napi_get_element(env, values, i, &key);
        // 获取 key 对应的值
        napi_value value;
        napi_get_property(env, args[0], key, &value);
        // 设置 index 位置的元素值为 key 对应的值
        napi_set_element(env, values, i, value);
    }
    return values;
}

napi_value Assign(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_get_cb_info(env, info, &argc, nullptr, nullptr, nullptr);
    napi_value *args = new napi_value[argc]{nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value target = args[0];
    for (int index = 1; index < argc; index++)
    {
        _Assign(env, target, args[index], false);
    }
    return target;
}

napi_value AssignDeep(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_get_cb_info(env, info, &argc, nullptr, nullptr, nullptr);
    napi_value *args = new napi_value[argc]{nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value target = args[0];
    for (int index = 1; index < argc; index++)
    {
        _Assign(env, target, args[index], true);
    }
    return target;
}

napi_value Copy(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 创建默认对象
    napi_value target;
    napi_create_object(env, &target);
    _Assign(env, target, args[0], false);
    return target;
}

napi_value Clone(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 创建默认对象
    napi_value target;
    napi_create_object(env, &target);
    _Assign(env, target, args[0], true);
    return target;
}
} // namespace object
}