import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

/**
 * 万年历数据接口
 */
export interface CalendarData {
  date: string;
  year: number;
  month: number;
  day: number;
  lunar_year: number;
  lunar_month: number;
  lunar_day: number;
  zodiac: string;
  year_gan: string;
  year_zhi: string;
  month_gan: string;
  month_zhi: string;
  day_gan: string;
  day_zhi: string;
  week_day: number;
  week_name: string;
  is_holiday: number;
  holiday_name: string;
  solar_term: string;
  festivals: string;
}

/**
 * 万年历工具类
 * 用于查询公历日期对应的农历信息
 */
export class LunarCalendar {
  private static instance: LunarCalendar;
  private calendarCache: Map<string, CalendarData> = new Map();
  private resMgr: resourceManager.ResourceManager | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): LunarCalendar {
    if (!LunarCalendar.instance) {
      LunarCalendar.instance = new LunarCalendar();
    }
    return LunarCalendar.instance;
  }

  /**
   * 初始化资源管理器
   */
  public async init(context: Context): Promise<void> {
    this.resMgr = context.resourceManager;
  }

  /**
   * 根据年份获取对应的JSON文件编号
   * 1900-2009: 0001-0011
   * 2010-2019: 0012
   * 2020-2029: 0013
   * ...
   * 2060-2061: 0017
   */
  private getFileNumber(year: number): string {
    if (year < 1900 || year > 2061) {
      return '';
    }

    if (year <= 2009) {
      const fileNum = Math.floor((year - 1900) / 10) + 1;
      return fileNum.toString().padStart(4, '0');
    } else {
      const fileNum = Math.floor((year - 2010) / 10) + 12;
      return fileNum.toString().padStart(4, '0');
    }
  }

  /**
   * 加载指定年份的万年历数据
   */
  private async loadCalendarData(year: number): Promise<CalendarData[]> {
    if (!this.resMgr) {
      console.error('资源管理器未初始化');
      return [];
    }

    const fileNumber = this.getFileNumber(year);
    if (!fileNumber) {
      console.error(`不支持的年份: ${year}，仅支持1900-2061年`);
      return [];
    }

    const fileName = `calendar/calendar_data_${fileNumber}.json`;
    
    try {
      const rawFileData = await this.resMgr.getRawFileContent(fileName);
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const uint8Array = new Uint8Array(rawFileData.buffer);
      const jsonStr = decoder.decodeWithStream(uint8Array, { stream: false });
      const data: CalendarData[] = JSON.parse(jsonStr) as CalendarData[];
      
      // 缓存数据
      data.forEach((item: CalendarData) => {
        this.calendarCache.set(item.date, item);
      });
      
      return data;
    } catch (err) {
      const error = err as BusinessError;
      console.error(`加载万年历数据失败: ${fileName}, 错误: ${error.message}`);
      return [];
    }
  }

  /**
   * 查询指定公历日期的详细信息
   * @param year 公历年份
   * @param month 公历月份 (1-12)
   * @param day 公历日期 (1-31)
   * @returns 日期详细信息，如果未找到返回null
   */
  public async getDateInfo(year: number, month: number, day: number): Promise<CalendarData | null> {
    const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    
    // 先从缓存查询
    if (this.calendarCache.has(dateStr)) {
      return this.calendarCache.get(dateStr) || null;
    }

    // 缓存未命中，加载数据
    try {
      await this.loadCalendarData(year);
      return this.calendarCache.get(dateStr) || null;
    } catch (err) {
      console.error(`查询日期信息失败: ${dateStr}`, err);
      return null;
    }
  }

  /**
   * 获取农历日期字符串
   * @param lunarMonth 农历月份
   * @param lunarDay 农历日期
   * @param isLeap 是否闰月（暂未使用）
   * @returns 格式化的农历日期，如"正月初一"
   */
  public static getLunarDateString(lunarMonth: number, lunarDay: number, isLeap: boolean = false): string {
    const monthNames = ['正月', '二月', '三月', '四月', '五月', '六月',
                        '七月', '八月', '九月', '十月', '冬月', '腊月'];
    const dayNames = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
                      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
                      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'];

    const monthStr = isLeap ? `闰${monthNames[lunarMonth - 1]}` : monthNames[lunarMonth - 1];
    const dayStr = dayNames[lunarDay - 1] || `${lunarDay}日`;

    return `${monthStr}${dayStr}`;
  }

  /**
   * 获取完整的农历描述
   * @param data 日期数据
   * @returns 格式化的农历描述，如"农历庚子年正月初一"
   */
  public static getFullLunarString(data: CalendarData): string {
    const lunarDateStr = LunarCalendar.getLunarDateString(data.lunar_month, data.lunar_day);
    return `农历${data.year_gan}${data.year_zhi}年${lunarDateStr}`;
  }

  /**
   * 清空缓存
   */
  public clearCache(): void {
    this.calendarCache.clear();
  }
}
