/**
 * 数据源
 */
export class UDataSource<T> implements IDataSource {
  /** 源列表 */
  protected origins: T[] = [];
  /** 监听列表 */
  private listeners: DataChangeListener[] = [];

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
  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 该方法为框架侧调用，为LazyForEach组件向其数据源处移除listener监听
   * @param listener 数据监听
   */
  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * 预加载数据
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
  public pushAll(items: T[]): void {
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
    this.listeners.forEach(listener => listener.onDataReloaded())
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处添加子组件
   * @param index 添加的位置
   */
  protected notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => listener.onDataAdd(index));
    // 写法2：listener.onDatasetChange([{type: DataOperationType.ADD, index: index}]);
  }

  /**
   * 通知 LazyForEach 组件在 index 对应索引处数据有变化，需要重建该子组件
   * @param index 改变的位置
   */
  protected notifyDataChange(index: number): void {
    this.listeners.forEach(listener => listener.onDataChange(index))
  }

  /**
   * 通知 LazyForEach 组件需要在index对应索引处删除该子组件
   * @param index 删除的位置
   */
  protected notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => listener.onDataDelete(index))
  }

  /**
   * 通知 LazyForEach 组件将 from 索引和 to 索引处的子组件进行交换
   * @param from
   * @param to
   */
  protected notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => listener.onDataMove(from, to))
  }

  /**
   * 通知数据集改变
   * @param operations 操作集合
   */
  protected notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach(listener => listener.onDatasetChange(operations))
  }
}