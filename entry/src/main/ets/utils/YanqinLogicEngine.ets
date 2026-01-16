import { CalendarData } from './LunarCalendar';

/**
 * 星宿节点数据
 */
export interface StarNode {
  name: string;        // 星宿名
  animal: string;      // 对应禽象
  element: string;     // 五行能量属性
  position: number;    // 轨道位置 (0-27)
  category: string;    // 所属星垣 (东宫/西宫等)
}

/**
 * 逻辑推演结果
 */
export interface DeductionResult {
  originStar: StarNode;       // 时空原点主星
  environmentalImpact: string; // 环境交互描述
  energyLevel: number;        // 能量能级 (0-100)
  logicSteps: string[];       // 推演步骤描述
}

export interface CycleResult {
  energyFlux: number;
  feedback: string;
}

/**
 * 演禽逻辑引擎
 * 将传统术数转化为时空坐标逻辑推演
 */
export class YanqinLogicEngine {
  private static instance: YanqinLogicEngine;
  
  // 二十八宿数据映射
  private readonly stars: string[] = [
    '角', '亢', '氐', '房', '心', '尾', '箕', // 东方青龙
    '斗', '牛', '女', '虚', '危', '室', '壁', // 北方玄武
    '奎', '娄', '胃', '昴', '毕', '觜', '参', // 西方白虎
    '井', '鬼', '柳', '星', '张', '翼', '轸'  // 南方朱雀
  ];

  private readonly elements: string[] = ['木', '金', '土', '日', '月', '火', '水'];

  private constructor() {}

  public static getInstance(): YanqinLogicEngine {
    if (!YanqinLogicEngine.instance) {
      YanqinLogicEngine.instance = new YanqinLogicEngine();
    }
    return YanqinLogicEngine.instance;
  }

  /**
   * 根据时空坐标执行逻辑推演
   * @param data 万年历数据
   * @param hourIndex 时辰索引 (0-11)
   */
  public deduce(data: CalendarData, hourIndex: number): DeductionResult {
    const steps: string[] = [];
    steps.push(`1. 定位时空原点：${data.date} ${hourIndex}时`);
    
    // 逻辑步骤：计算主星坐标 (模拟演禽算法)
    // 实际算法应根据 data.lunar_month, data.lunar_day 等计算，这里先实现逻辑框架
    const starIndex = (data.lunar_day + hourIndex) % 28;
    const originStar: StarNode = {
      name: this.stars[starIndex],
      animal: this.getAnimalForStar(this.stars[starIndex]),
      element: this.elements[starIndex % 7],
      position: starIndex,
      category: this.getCategory(starIndex)
    };
    
    steps.push(`2. 映射时空主星：${originStar.name}宿 (${originStar.animal})`);
    steps.push(`3. 识别能量属性：${originStar.element}能级`);
    
    // 逻辑步骤：计算环境交互 (模拟吞啖逻辑)
    const impact = this.calculateEnvironmentalImpact(originStar, data);
    steps.push(`4. 分析环境交互逻辑：${impact.substring(0, 15)}...`);
    
    return {
      originStar: originStar,
      environmentalImpact: impact,
      energyLevel: 75 + (starIndex % 20), // 模拟计算出的能量值
      logicSteps: steps
    };
  }

  private getAnimalForStar(starName: string): string {
    const animals: Record<string, string> = {
      '角': '木蛟', '亢': '金龙', '氐': '土貉', '房': '日兔', '心': '月狐', '尾': '火虎', '箕': '水豹',
      '斗': '木獬', '牛': '金牛', '女': '土蝠', '虚': '日鼠', '危': '月燕', '室': '火猪', '壁': '水獝',
      '奎': '木狼', '娄': '金狗', '胃': '土雉', '昴': '日鸡', '毕': '月乌', '觜': '火猴', '参': '水猿',
      '井': '木犴', '鬼': '金羊', '柳': '土獐', '星': '日马', '张': '月鹿', '翼': '火蛇', '轸': '水蚯'
    };
    return animals[starName] || '未知';
  }

  private getCategory(index: number): string {
    if (index < 7) return '东方青龙垣';
    if (index < 14) return '北方玄武垣';
    if (index < 21) return '西方白虎垣';
    return '南方朱雀垣';
  }

  private calculateEnvironmentalImpact(star: StarNode, data: CalendarData): string {
    return `当前时空主星 ${star.name} 在 ${data.year_gan}${data.year_zhi} 周期环境下，呈现 ${star.element} 属性的正向逻辑反馈。环境变量平衡，建议在此逻辑模型下执行既定规划。`;
  }

  /**
   * 获取宿星生态克制关系 (吞啖)
   */
  public getEcologyRelation(starName: string): string[] {
    const relations: Record<string, string[]> = {
      '角': ['吞：胃、觜', '啖：星、张'],
      '亢': ['吞：毕、参', '啖：翼、轸'],
      '氐': ['吞：柳、鬼', '啖：斗、牛'],
      // 示例数据，实际应根据 tundan_explanation.md 填充
    };
    return relations[starName] || ['暂无详细生态逻辑记录'];
  }

  /**
   * 执行周期模拟推演 (流年干涉)
   * @param originStar 初始时空主星
   * @param targetYear 模拟的目标年份
   */
  public simulateCycle(originStar: StarNode, targetYear: number): CycleResult {
    // 逻辑：计算目标年份的年宿 (模拟算法)
    const yearStarIndex = (targetYear - 1900) % 28;
    
    // 计算初始主星与周期主星的相位差
    const phaseDiff = Math.abs(originStar.position - yearStarIndex);
    
    // 模拟能场干涉逻辑
    let flux = 50; 
    let fb = '';

    if (phaseDiff === 0) {
      flux = 95;
      fb = `初始主星 ${originStar.name} 与模拟周期主星重合，产生“共振效应”，逻辑能级达到峰值。`;
    } else if (phaseDiff % 7 === 0) {
      flux = 80;
      fb = `初始主星 ${originStar.name} 与模拟周期主星形成“协同相位”，逻辑传导顺畅。`;
    } else if (phaseDiff < 7) {
      flux = 30;
      fb = `初始主星 ${originStar.name} 受到模拟周期主星的“强力干涉”，逻辑波动剧烈，建议保持静态观察。`;
    } else {
      flux = 60;
      fb = `初始主星 ${originStar.name} 在 ${targetYear} 周内呈现“稳态反馈”，环境因子干扰较小。`;
    }

    const res: CycleResult = { energyFlux: flux, feedback: fb };
    return res;
  }

  /**
   * 获取环境变量化象 (化道)
   */
  public getEnvironmentalTransformation(gan: string, zhi: string): string {
    return `${gan}${zhi} 组合在当前逻辑下转化为“中性环境变量”，对星宿能量场无显著干扰。`;
  }
}
