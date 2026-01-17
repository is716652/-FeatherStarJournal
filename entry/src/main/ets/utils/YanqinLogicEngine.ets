import { CalendarData } from './LunarCalendar';
import common from '@ohos.app.ability.common';
import { util } from '@kit.ArkTS';

/**
 * 星宿数据接口 (来自 animals.json)
 */
export interface AnimalData {
  star: string;
  element: string;
  animal: string;
  full_name: string;
}

/**
 * 吞啖关系接口 (来自 interactions.json)
 */
export interface InteractionData {
  star: string;
  eats: string[];
  fears: string[];
  source_text: string;
  note: string;
}

/**
 * 化道环境接口 (来自 transformations.json)
 */
export interface TransformationData {
  jiazi_map: Record<string, string[]>;
  stem_map: Record<string, string[]>;
  branch_map: Record<string, string[]>;
}

/**
 * 星宿节点数据
 */
export interface StarNode {
  name: string;        // 星宿名
  animal: string;      // 对应禽象
  element: string;     // 七曜属性
  position: number;    // 轨道位置 (0-27)
  category: string;    // 所属星垣 (东宫/西宫等)
  fullName: string;    // 全名 (如：角木蛟)
}

/**
 * 逻辑推演结果
 */
export interface DeductionResult {
  originStar: StarNode;       // 时空原点主星 (主星)
  fetalStar: StarNode;        // 胎星
  destinyStar: StarNode;      // 命星
  environmentalImpact: string; // 环境交互描述
  ecologyStatus: string;       // 生态克制状态
  energyLevel: number;        // 能量能级 (0-100)
  logicSteps: string[];       // 推演步骤描述
}

export interface CycleResult {
  energyFlux: number;
  feedback: string;
}

/**
 * 演禽逻辑引擎
 * 基于真实算法实现时空坐标逻辑推演
 */
export class YanqinLogicEngine {
  private static instance: YanqinLogicEngine;
  
  // 二十八宿数据映射 (按序排列)
  private readonly stars: string[] = [
    '角', '亢', '氐', '房', '心', '尾', '箕', // 东方青龙
    '斗', '牛', '女', '虚', '危', '室', '壁', // 北方玄武
    '奎', '娄', '胃', '昴', '毕', '觜', '参', // 西方白虎
    '井', '鬼', '柳', '星', '张', '翼', '轸'  // 南方朱雀
  ];

  // JSON 数据缓存
  private animalsData: AnimalData[] = [];
  private interactionsData: InteractionData[] = [];
  private transformationsData: TransformationData | null = null;
  private seasonalData: Record<string, string[]> = {};
  private dataLoaded: boolean = false;

  private constructor() {
    this.loadData();
  }

  public static getInstance(): YanqinLogicEngine {
    if (!YanqinLogicEngine.instance) {
      YanqinLogicEngine.instance = new YanqinLogicEngine();
    }
    return YanqinLogicEngine.instance;
  }

  /**
   * 加载所有 JSON 数据 (使用 util.TextDecoder，与 LunarCalendar 保持一致)
   */
  private async loadData(): Promise<void> {
    if (this.dataLoaded) return;

    try {
      const context = getContext(this) as common.UIAbilityContext;
      const mgr = context.resourceManager;
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });

      // 加载 animals.json
      const animalsRaw = await mgr.getRawFileContent('animals.json');
      const animalsStr = decoder.decodeWithStream(new Uint8Array(animalsRaw.buffer), { stream: false });
      this.animalsData = JSON.parse(animalsStr) as AnimalData[];

      // 加载 interactions.json
      const interactionsRaw = await mgr.getRawFileContent('interactions.json');
      const interactionsStr = decoder.decodeWithStream(new Uint8Array(interactionsRaw.buffer), { stream: false });
      const interactionsObj = JSON.parse(interactionsStr) as Record<string, InteractionData[]>;
      this.interactionsData = interactionsObj.relationships;

      // 加载 transformations.json
      const transformationsRaw = await mgr.getRawFileContent('transformations.json');
      const transformationsStr = decoder.decodeWithStream(new Uint8Array(transformationsRaw.buffer), { stream: false });
      this.transformationsData = JSON.parse(transformationsStr) as TransformationData;

      // 加载 seasonal_strength.json
      const seasonalRaw = await mgr.getRawFileContent('seasonal_strength.json');
      const seasonalStr = decoder.decodeWithStream(new Uint8Array(seasonalRaw.buffer), { stream: false });
      this.seasonalData = JSON.parse(seasonalStr) as Record<string, string[]>;

      this.dataLoaded = true;
    } catch (err) {
      console.error('[YanqinLogicEngine] 数据加载失败:', JSON.stringify(err));
    }
  }

  /**
   * 根据时空坐标执行逻辑推演
   * @param data 万年历数据
   * @param hourIndex 时辰索引 (0-11)
   */
  public async deduce(data: CalendarData, hourIndex: number): Promise<DeductionResult> {
    // 确保数据已加载
    await this.loadData();
    
    const steps: string[] = [];
    steps.push(`1. 定位时空原点：${data.date} ${this.getHourName(hourIndex)}时`);
    
    // 算法步骤：计算主星、胎星、命星
    const mainStarIndex = this.calculateMainStar(data.lunar_month, data.lunar_day);
    const fetalStarIndex = this.calculateFetalStar(data.lunar_month);
    const destinyStarIndex = this.calculateDestinyStar(mainStarIndex, hourIndex);
    
    const originStar = this.createStarNode(mainStarIndex);
    const fetalStar = this.createStarNode(fetalStarIndex);
    const destinyStar = this.createStarNode(destinyStarIndex);
    
    steps.push(`2. 映射时空主星：${originStar.fullName} (位置 ${mainStarIndex + 1})`);
    steps.push(`3. 计算胎星：${fetalStar.fullName} (位置 ${fetalStarIndex + 1})`);
    steps.push(`4. 推演命星：${destinyStar.fullName} (位置 ${destinyStarIndex + 1})`);
    
    // 计算生态克制状态 (吞啖逻辑)
    const ecologyStatus = this.calculateEcology(originStar, data);
    steps.push(`5. 分析生态克制：${ecologyStatus.substring(0, 20)}...`);
    
    // 计算环境交互 (化道逻辑)
    const impact = this.calculateEnvironmentalImpact(originStar, data);
    steps.push(`6. 分析环境交互：${impact.substring(0, 20)}...`);
    
    // 计算四时生旺
    const seasonStrength = this.calculateSeasonalStrength(originStar, data.lunar_month);
    steps.push(`7. 评估四时生旺：${seasonStrength > 70 ? '旺相' : seasonStrength > 40 ? '休囚' : '囚死'}`);
    
    // 综合能量评估
    const energyLevel = Math.floor((seasonStrength + this.evaluateEcologyEnergy(ecologyStatus)) / 2);
    
    return {
      originStar: originStar,
      fetalStar: fetalStar,
      destinyStar: destinyStar,
      environmentalImpact: impact,
      ecologyStatus: ecologyStatus,
      energyLevel: energyLevel,
      logicSteps: steps
    };
  }

  /**
   * 计算主星（基于农历月日）
   * 算法：(月 + 日) % 28
   */
  private calculateMainStar(lunarMonth: number, lunarDay: number): number {
    return (lunarMonth + lunarDay - 1) % 28;
  }

  /**
   * 计算胎星（基于农历月份）
   * 算法：月 * 2 % 28
   */
  private calculateFetalStar(lunarMonth: number): number {
    return (lunarMonth * 2) % 28;
  }

  /**
   * 计算命星（基于主星 + 时辰）
   * 算法：(主星 + 时辰) % 28
   */
  private calculateDestinyStar(mainStarIndex: number, hourIndex: number): number {
    return (mainStarIndex + hourIndex) % 28;
  }

  /**
   * 创建星宿节点对象
   */
  private createStarNode(index: number): StarNode {
    const starName = this.stars[index];
    const animalInfo = this.animalsData.find(a => a.star === starName);
    
    return {
      name: starName,
      animal: animalInfo?.animal || '未知',
      element: animalInfo?.element || '未知',
      position: index,
      category: this.getCategory(index),
      fullName: animalInfo?.full_name || `${starName}宿`
    };
  }

  /**
   * 获取时辰名称
   */
  private getHourName(index: number): string {
    const hours = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    return hours[index] || '未知';
  }

  /**
   * 计算生态克制状态 (吞啖逻辑)
   */
  private calculateEcology(star: StarNode, data: CalendarData): string {
    // 计算流年星（基于年份）
    const yearStarIndex = (data.year - 1900) % 28;
    const yearStar = this.stars[yearStarIndex];
    const yearAnimal = this.animalsData.find(a => a.star === yearStar)?.animal || '未知';
      
    // 查找当前主星在十二宫位的吞啖关系
    const branchRelation = this.interactionsData.find(r => 
      r.eats.includes(star.animal) || r.fears.includes(star.animal)
    );
      
    let status = '中性状态';
      
    if (branchRelation) {
      if (branchRelation.eats.includes(yearAnimal)) {
        status = `主星 ${star.fullName} 克制流年星 ${yearStar}宿 (${yearAnimal})，处于优势地位。${branchRelation.note ? '注：' + branchRelation.note : ''}`;
      } else if (branchRelation.fears.includes(yearAnimal)) {
        status = `主星 ${star.fullName} 被流年星 ${yearStar}宿 (${yearAnimal}) 克制，处于劣势地位。${branchRelation.note ? '注：' + branchRelation.note : ''}`;
      }
    } else {
      status = `主星 ${star.fullName} 与流年星 ${yearStar}宿 (${yearAnimal}) 无直接生态克制关系，处于中性状态。`;
    }
      
    return status;
  }
  
  /**
   * 计算环境交互 (化道逻辑)
   */
  private calculateEnvironmentalImpact(star: StarNode, data: CalendarData): string {
    if (!this.transformationsData) {
      return `当前时空主星 ${star.fullName} 在 ${data.year_gan}${data.year_zhi} 周期环境下，呈现中性逻辑反馈。`;
    }
      
    const jiazi = `${data.year_gan}${data.year_zhi}`;
    const environments = this.transformationsData.jiazi_map[jiazi] || 
                         this.transformationsData.stem_map[data.year_gan] || 
                         this.transformationsData.branch_map[data.year_zhi] || 
                         ['未知环境'];
      
    const envStr = environments.join('、');
      
    // 简单判断：如果环境包含禽象适宜的地形，则吉
    const favorableEnvs = ['山林', '水泽', '草原', '江河'];
    const isFavorable = environments.some(env => favorableEnvs.some(fe => env.includes(fe)));
      
    if (isFavorable) {
      return `主星 ${star.fullName} 在 ${jiazi} 周期环境下，处于 ${envStr} 的有利地形，逻辑反馈正向。`;
    } else {
      return `主星 ${star.fullName} 在 ${jiazi} 周期环境下，处于 ${envStr} 环境，需谨慎观察逻辑波动。`;
    }
  }
  
  /**
   * 计算四时生旺 (返回 0-100 的强度值)
   */
  private calculateSeasonalStrength(star: StarNode, lunarMonth: number): number {
    let season: string;
      
    if (lunarMonth >= 1 && lunarMonth <= 3) {
      season = 'spring';
    } else if (lunarMonth >= 4 && lunarMonth <= 6) {
      season = 'summer';
    } else if (lunarMonth >= 7 && lunarMonth <= 9) {
      season = 'autumn';
    } else {
      season = 'winter';
    }
      
    const seasonalStars = this.seasonalData[season] || [];
      
    if (seasonalStars.includes(star.name)) {
      return 85; // 旺相
    } else {
      return 50; // 休囚/囚死
    }
  }
  
  /**
   * 根据生态状态评估能量
   */
  private evaluateEcologyEnergy(status: string): number {
    if (status.includes('优势')) {
      return 80;
    } else if (status.includes('劣势')) {
      return 30;
    } else {
      return 55;
    }
  }

  private getCategory(index: number): string {
    if (index < 7) return '东方青龙垣';
    if (index < 14) return '北方玄武垣';
    if (index < 21) return '西方白虎垣';
    return '南方朱雀垣';
  }

  /**
   * 获取宿星生态克制关系 (吞啖) - 用于 StarEcology 页面
   */
  public async getEcologyRelation(starName: string): Promise<string[]> {
    await this.loadData();
    
    const animalInfo = this.animalsData.find(a => a.star === starName);
    if (!animalInfo) return ['暂无详细生态逻辑记录'];
    
    const relation = this.interactionsData.find(r => r.star.includes(animalInfo.animal));
    if (!relation) return ['暂无详细生态逻辑记录'];
    
    const result: string[] = [];
    result.push(`吞：${relation.eats.join('、')}`);
    result.push(`啖：${relation.fears.join('、')}`);
    if (relation.note) {
      result.push(`注：${relation.note}`);
    }
    
    return result;
  }

  /**
   * 执行周期模拟推演 (流年干扰) - 真实算法版本
   * @param originStar 初始时空主星
   * @param targetYear 模拟的目标年份
   */
  public async simulateCycle(originStar: StarNode, targetYear: number): Promise<CycleResult> {
    await this.loadData();
      
    // 计算目标年份的流年星
    const yearStarIndex = (targetYear - 1900) % 28;
    const yearStar = this.stars[yearStarIndex];
    const yearAnimal = this.animalsData.find(a => a.star === yearStar)?.animal || '未知';
      
    // 计算相位差
    const phaseDiff = Math.abs(originStar.position - yearStarIndex);
      
    // 查询吞啖关系
    const relation = this.interactionsData.find(r => 
      r.eats.includes(originStar.animal) || r.fears.includes(originStar.animal)
    );
      
    let flux = 50;
    let fb = '';
      
    if (phaseDiff === 0) {
      flux = 95;
      fb = `初始主星 ${originStar.fullName} 与模拟年份 ${targetYear} 的流年星重合，产生“共振效应”，逻辑能级达到峰值。`;
    } else if (relation && relation.eats.includes(yearAnimal)) {
      flux = 80;
      fb = `初始主星 ${originStar.fullName} 克制流年星 ${yearStar}宿 (${yearAnimal})，周期逻辑传导顺畅。`;
    } else if (relation && relation.fears.includes(yearAnimal)) {
      flux = 30;
      fb = `初始主星 ${originStar.fullName} 被流年星 ${yearStar}宿 (${yearAnimal}) 克制，受到强力干扰，建议保持静态观察。`;
    } else if (phaseDiff % 7 === 0) {
      flux = 70;
      fb = `初始主星 ${originStar.fullName} 与流年星 ${yearStar}宿形成“协同相位”，逻辑波动平稳。`;
    } else {
      flux = 60;
      fb = `初始主星 ${originStar.fullName} 在 ${targetYear} 周内呈现“稳态反馈”，环境因子干扰较小。`;
    }
      
    const res: CycleResult = { energyFlux: flux, feedback: fb };
    return res;
  }

  /**
   * 获取环境变量化象 (化道) - 用于 EnvironmentalVariables 页面
   */
  public async getEnvironmentalTransformation(gan: string, zhi: string): Promise<string> {
    await this.loadData();
    
    if (!this.transformationsData) {
      return `${gan}${zhi} 组合在当前逻辑下转化为“中性环境变量”。`;
    }
    
    const jiazi = `${gan}${zhi}`;
    const environments = this.transformationsData.jiazi_map[jiazi] || 
                         this.transformationsData.stem_map[gan] || 
                         this.transformationsData.branch_map[zhi] || 
                         ['未知环境'];
    
    return `${jiazi} 组合在当前逻辑下转化为：${environments.join('、')}。这些环境意象将影响星宿能量场的表达。`;
  }

  /**
   * 获取所有星宿列表 - 用于 UI 展示
   */
  public getAllStars(): string[] {
    return this.stars;
  }

  /**
   * 获取星宿详细信息 - 用于全景图
   */
  public async getStarDetail(starName: string): Promise<AnimalData | null> {
    await this.loadData();
    return this.animalsData.find(a => a.star === starName) || null;
  }
}
