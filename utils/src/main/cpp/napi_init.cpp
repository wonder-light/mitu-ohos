#include "napi/native_api.h"
#include "object.h"
#include "thread.h"


EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"keys", nullptr, utils::object::Keys, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"values", nullptr, utils::object::Values, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"assign", nullptr, utils::object::Assign, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"assignDeep", nullptr, utils::object::AssignDeep, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"copy", nullptr, utils::object::Copy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"clone", nullptr, utils::object::Clone, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startThread", nullptr, utils::thread::StartThread, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "utils",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterUtilsModule(void) { napi_module_register(&demoModule); }
