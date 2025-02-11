export type AsyncCallback<T, V = void> = (data: T) => Promise<V>;

export type AsyncCallback2<T, K = T, V = void> = (param1: T, param2: K) => Promise<V>;

export type AsyncCallback3<T, K = T, H = T, V = void> = (param1: T, param2: K, param3: H) => Promise<V>;