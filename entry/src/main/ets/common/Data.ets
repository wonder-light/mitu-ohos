import { HashMap, HashSet } from '@kit.ArkTS';
import { BasicPrefetcher, IDataSourcePrefetching } from '@kit.ArkUI';
import { AsyncCallback } from './Type';

type ICallback<T> = AsyncCallback<number, T>;

/** 数据源数据接口 */
export declare interface IDataSource<T> {
  /** 源列表 */
  origins?: T[];

  /** 预加载回调 */
  preloadCallback?: ICallback<T>;

  /** 预加载器 */
  prefetcher?: BasicPrefetcher;
}

/**
 * 数据源
 */
export class UDataSource<T> implements IDataSourcePrefetching {

  /** 源列表 */
  protected origins: T[];
  /** 监听列表 */
  protected listeners: HashSet<DataChangeListener | VoidCallback> = new HashSet();
  /** 预加载操作集合 */
  protected preloads: HashMap<number, Promise<void>> = new HashMap();
  /** 预加载回调 */
  protected preloadCallback?: ICallback<T>;
  /** 预加载器 */
  protected prefetcher?: BasicPrefetcher;

  constructor(item?: IDataSource<T>) {
    this.origins = item?.origins || [];
    this.preloadCallback = item?.preloadCallback;
    this.prefetcher = item?.prefetcher;
    if (this.prefetcher) this.prefetcher.setDataSource(this);
  }

  /**
   * 预取数据集合中指定元素的数据。
   * 此方法可以是同步的，也可以是异步的
   * @param index 集合中项的索引
   * @returns
   */
  public prefetch(index: number): void | Promise<void> {
    if (!this.preloadCallback || !this.origins[index]) return;
    if (this.preloads.hasKey(index)) return;
    // 预加载数据
    this.preloads.set(index, this.execute(index));
  }

  /**
   * 取消为数据集合中的指定元素预取数据。
   此方法可以是同步的，也可以是异步的
   * @param index 集合中项的索引
   * @returns
   */
  public cancel?(index: number): void | Promise<void> { }

  /** 设置预加载函数 */
  public setPreloadFun(callback: ICallback<T>): void {
    this.preloadCallback = callback;
  }

  /**
   * 当可见区域发生变化时调用此方法
   *
   * @param minVisible - 第一个可见数据项的索引
   * @param maxVisible - 最后一个可见数据项的索引
   */
  public visibleAreaChanged(minVisible: number, maxVisible: number): void {
    if (this.prefetcher == null) {
      this.prefetcher = new BasicPrefetcher(this);
    }
    this.prefetcher.visibleAreaChanged(minVisible, maxVisible);
  }

  /**
   * 获取数据源中数据总数
   */
  public totalCount(): number {
    return this.origins.length;
  }

  /**
   * 获取数据源中指定索引的数据
   * @param index 索引
   * @returns
   */
  public getData(index: number): T {
    return this.origins[index];
  }

  /**
   * 获取数据源中所有数据
   */
  public getAllData(): T[] {
    return this.origins;
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
   * @param listener 数据监听
   */
  public registerDataChangeListener(listener: DataChangeListener | VoidCallback): void {
    if (!this.listeners.has(listener)) {
      this.listeners.add(listener);
    }
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处移除listener监听
   * @param listener 数据监听
   */
  public unregisterDataChangeListener(listener: DataChangeListener | VoidCallback): void {
    this.listeners.remove(listener);
  }

  /**
   * 重新加载数据
   */
  public reload(): void {
    this.notifyDataReload();
  }

  /**
   * 添加数据
   * @param data 数据
   */
  public push(data: T): void {
    this.origins.push(data);
    this.notifyDataAdd(this.origins.length - 1);
  }

  /**
   * 添加数据集合
   * @param items
   */
  public pushAll(items: T | T[]): void {
    if (!(items instanceof Array)) {
      this.push(items);
      return;
    }
    const form = this.origins.length - 1;
    this.origins.push(...items);
    this.notifyDatasetChange([
      {
        type: DataOperationType.ADD,
        index: form,
        count: items.length
      }
    ]);
  }

  /**
   * 清空数据
   */
  public clear(): void {
    const length = this.origins.length;
    this.origins = [];
    this.notifyDatasetChange([
      {
        type: DataOperationType.DELETE,
        index: 0,
        count: length
      }
    ]);
  }

  /**
   * 删除数据
   * @param index 位置索引
   */
  public delete(index: number): void {
    this.origins.splice(index, 1);
    this.notifyDataDelete(index);
  }

  /**
   * 删除数据集合
   * @param items
   */
  public deleteAll(items: T[]): void {
    let lists = items.map((item) => this.origins.indexOf(item));
    lists = lists.filter((item) => item >= 0).sort().reverse();
    for (let index of lists) {
      this.origins.splice(index, 1);
    }
    let operations = lists.map((_, index): DataOperation => ({
      type: DataOperationType.DELETE,
      index: index,
      count: 1
    }));
    this.notifyDatasetChange(operations);
  }

  /**
   * 交换数据
   * @param from
   * @param to
   */
  public move(from: number, to: number): void {
    let temp: T = this.origins[from];
    this.origins[from] = this.origins[to];
    this.origins[to] = temp;
    this.notifyDataMove(from, to);
  }

  /**
   * 修改 index 索引处的数据
   * @param index
   * @param data
   */
  public change(index: number, data: T): void {
    this.origins.splice(index, 1, data);
    this.notifyDataChange(index);
  }

  /**
   * 通知 LazyForEach 组件需要重载所有子组件
   */
  protected notifyDataReload(): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDataReloaded();
    }
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处添加子组件
   * @param index 添加的位置
   */
  protected notifyDataAdd(index: number): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDataAdd(index);
    }
  }

  /**
   * 通知 LazyForEach 组件在 index 对应索引处数据有变化，需要重建该子组件
   * @param index 改变的位置
   */
  protected notifyDataChange(index: number): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDataChange(index);
    }
  }

  /**
   * 通知 LazyForEach 组件需要在index对应索引处删除该子组件
   * @param index 删除的位置
   */
  protected notifyDataDelete(index: number): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDataDelete(index);
    }
  }

  /**
   * 通知 LazyForEach 组件将 from 索引和 to 索引处的子组件进行交换
   * @param from
   * @param to
   */
  protected notifyDataMove(from: number, to: number): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDataMove(from, to);
    }
  }

  /**
   * 通知数据集改变
   * @param operations 操作集合
   */
  protected notifyDatasetChange(operations: DataOperation[]): void {
    for (let listener of this.listeners) {
      typeof listener === 'function' ? listener() : listener.onDatasetChange(operations);
    }
  }

  /** 执行预加载回调 */
  protected async execute(index: number) {
    this.origins[index] = await this.preloadCallback!(index);
    this.preloads.remove(index);
  }
}