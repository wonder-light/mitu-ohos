/** 获取对象的键 */
export declare function keys(target: Object): string[];

/** 获取对象的值 */
export declare function values(target: Object): Object[];

/** 分配对象属性 */
export declare function assign<T extends Object, U>(target: T, source: U): T & U;

/** 分配对象属性 */
export declare function assign<T extends Object, U, V>(target: T, source1: U, source2: V): T & U & V;

/** 分配对象属性 */
export declare function assign<T extends Object, U, V, W>(target: T, source1: U, source2: V, source3: W): T & U & V & W;

/** 分配对象属性 */
export declare function assign<T extends Object>(target: T, ...sources: Object[]): T & Object;

/** 深度分配对象属性 */
export declare function assignDeep<T extends Object, U>(target: T, source: U): T & U;

/** 深度分配对象属性 */
export declare function assignDeep<T extends Object, U, V>(target: T, source1: U, source2: V): T & U & V;

/** 深度分配对象属性 */
export declare function assignDeep<T extends Object, U, V, W>(target: T, source1: U, source2: V, source3: W): T & U & V & W;

/** 深度分配对象属性 */
export declare function assignDeep<T extends Object>(target: T, ...sources: Object[]): T & Object;

/** 创建一个 对象的浅拷贝 */
export declare function copy<T extends Object>(target: T): T;

/** 创建一个 对象的深拷贝 */
export declare function clone<T extends Object>(target: T): T;

/** 创建一个线程 */
export declare function startThread<T extends Object>(func: (...args: Object[]) => T, ...args: Object[]): Promise<T>;

