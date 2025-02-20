export type Callback<T, V = void> = (data: T) => V;

export type Callback2<T, K = T, V = void> = (param1: T, param2: K) => V;

export type Callback3<T, K = T, H = T, V = void> = (param1: T, param2: K, param3: H) => V;

export type CallbackParams<T = Object, V = void> = (...params: T[]) => V;

export type AsyncCallback<T, V = void> = (data: T) => Promise<V>;

export type AsyncCallback2<T, K = T, V = void> = (param1: T, param2: K) => Promise<V>;

export type AsyncCallback3<T, K = T, H = T, V = void> = (param1: T, param2: K, param3: H) => Promise<V>;

export type AsyncCallbackParams<T = Object, V = Promise<void>> = (...params: T[]) => V;

export type TCustomBuilder = CallbackParams;

export type TParserCallback<T> = AsyncCallback2<string, Record<string, Object>, T>;

export type TAny = any;

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS' | 'CONNECT' | 'TRACE';