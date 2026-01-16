/**
 * 研习成就管理类
 */
export class AchievementManager {
  private static instance: AchievementManager;
  private readonly STORAGE_KEY = 'UnlockedStars';
  
  private constructor() {
    // 初始化持久化存储
    if (!AppStorage.has(this.STORAGE_KEY)) {
      AppStorage.setOrCreate(this.STORAGE_KEY, []);
    }
  }

  public static getInstance(): AchievementManager {
    if (!AchievementManager.instance) {
      AchievementManager.instance = new AchievementManager();
    }
    return AchievementManager.instance;
  }

  /**
   * 解锁星宿研习记录
   */
  public unlockStar(starName: string): void {
    const unlocked: string[] = AppStorage.get<string[]>(this.STORAGE_KEY) || [];
    if (!unlocked.includes(starName)) {
      unlocked.push(starName);
      AppStorage.set(this.STORAGE_KEY, unlocked);
      console.info(`研习点亮：${starName}`);
    }
  }

  /**
   * 获取解锁进度 (0-100)
   */
  public getProgress(): number {
    const unlocked: string[] = AppStorage.get<string[]>(this.STORAGE_KEY) || [];
    return Math.floor((unlocked.length / 28) * 100);
  }

  /**
   * 检查是否获得“大成印记”勋章
   */
  public isAllUnlocked(): boolean {
    const unlocked: string[] = AppStorage.get<string[]>(this.STORAGE_KEY) || [];
    return unlocked.length >= 28;
  }

  /**
   * 获取已点亮的数量
   */
  public getUnlockedCount(): number {
    const unlocked: string[] = AppStorage.get<string[]>(this.STORAGE_KEY) || [];
    return unlocked.length;
  }
}
