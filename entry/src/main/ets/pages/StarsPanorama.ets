import router from '@ohos.router';
import { YanqinLogicEngine, AnimalData } from '../utils/YanqinLogicEngine';

/**
 * 四象颜色配置接口
 */
interface QuadrantColors {
  east: string;
  north: string;
  west: string;
  south: string;
}

/**
 * 28星宿全景图页面
 * 使用 Canvas 绘制交互式星宿轨道图
 */
@Entry
@Component
struct StarsPanorama {
  @State canvasWidth: number = 0;
  @State canvasHeight: number = 0;
  @State selectedStar: string = '';
  @State selectedStarDetail: AnimalData | null = null;
  @State currentUserStar: string = ''; // 用户的主星
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private logicEngine: YanqinLogicEngine = YanqinLogicEngine.getInstance();
  private stars: string[] = [];
  
  // 四象配色方案
  private readonly colors: QuadrantColors = {
    east: '#00CED1',    // 青龙 - 青色
    north: '#000080',   // 玄武 - 深蓝
    west: '#FFD700',    // 白虎 - 金色
    south: '#FF4500'    // 朱雀 - 红色
  };

  async aboutToAppear() {
    this.stars = this.logicEngine.getAllStars();
    
    // 获取用户当前主星（从路由参数或本地存储）
    const params = router.getParams() as Record<string, string>;
    if (params && params['userStar']) {
      this.currentUserStar = params['userStar'];
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#D4AF37')
          .onClick(() => {
            router.back();
          })
        
        Text('二十八宿全景图')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D4AF37')
          .margin({ left: 12 })
        
        Blank()
        
        Text('点击星宿查看详情')
          .fontSize(12)
          .fontColor('#888888')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#1A1A1A')

      // Canvas 绘制区域
      Canvas(this.renderContext)
        .width('100%')
        .height('70%')
        .backgroundColor('#000000')
        .onReady(() => {
          // 获取 Canvas 实际尺寸
          this.canvasWidth = this.renderContext.width;
          this.canvasHeight = this.renderContext.height;
          console.info(`[StarsPanorama] Canvas size: ${this.canvasWidth} x ${this.canvasHeight}`);
          this.drawStarMap();
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down) {
            this.handleCanvasTouch(event.touches[0].x, event.touches[0].y);
          }
        })

      // 底部详情展示区
      Column() {
        if (this.selectedStarDetail) {
          Column() {
            Text(this.selectedStarDetail.full_name)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D4AF37')
              .margin({ bottom: 8 })
            
            Row() {
              Text(`星宿：${this.selectedStarDetail.star}`)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .margin({ right: 20 })
              
              Text(`七曜：${this.selectedStarDetail.element}`)
                .fontSize(16)
                .fontColor('#FFFFFF')
                .margin({ right: 20 })
              
              Text(`禽象：${this.selectedStarDetail.animal}`)
                .fontSize(16)
                .fontColor('#FFFFFF')
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#1A1A1A')
          .borderRadius(12)
        } else {
          Column() {
            Text('点击星宿查看详情')
              .fontSize(16)
              .fontColor('#888888')
          }
          .width('100%')
          .height(100)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('90%')
      .margin({ top: 20 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  /**
   * 绘制星宿全景图
   */
  private drawStarMap() {
    if (!this.renderContext || this.canvasWidth === 0 || this.canvasHeight === 0) {
      console.warn('[StarsPanorama] Canvas not ready');
      return;
    }

    const ctx = this.renderContext;
    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight / 2;
    const radius = Math.min(centerX, centerY) * 0.7; // 调整半径使星宿名称不被截断

    // 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    // 绘制背景渐变
    this.drawBackground(ctx, centerX, centerY, radius);

    // 绘制四象分区连线
    this.drawQuadrantLines(ctx, centerX, centerY, radius);

    // 绘制轨道圆环
    this.drawOrbit(ctx, centerX, centerY, radius);

    // 绘制 28 星宿
    this.drawStars(ctx, centerX, centerY, radius);

    // 绘制中心标记
    this.drawCenterMark(ctx, centerX, centerY);
  }

  /**
   * 绘制背景渐变
   */
  private drawBackground(ctx: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    // 径向渐变背景
    const gradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius * 1.2);
    gradient.addColorStop(0, '#1a0033');
    gradient.addColorStop(0.5, '#0d001a');
    gradient.addColorStop(1, '#000000');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight);
  }

  /**
   * 绘制四象分区连线
   */
  private drawQuadrantLines(ctx: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    ctx.strokeStyle = '#333333';
    ctx.lineWidth = 1;
    ctx.setLineDash([5, 5]);

    // 东方青龙 (0-6): 右侧
    // 北方玄武 (7-13): 上方
    // 西方白虎 (14-20): 左侧
    // 南方朱雀 (21-27): 下方
    
    // 垂直线
    ctx.beginPath();
    ctx.moveTo(centerX, centerY - radius * 1.1);
    ctx.lineTo(centerX, centerY + radius * 1.1);
    ctx.stroke();

    // 水平线
    ctx.beginPath();
    ctx.moveTo(centerX - radius * 1.1, centerY);
    ctx.lineTo(centerX + radius * 1.1, centerY);
    ctx.stroke();

    ctx.setLineDash([]);
  }

  /**
   * 绘制轨道圆环
   */
  private drawOrbit(ctx: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    ctx.strokeStyle = '#D4AF37';
    ctx.lineWidth = 2;
    ctx.globalAlpha = 0.3;
    
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
    ctx.stroke();
    
    ctx.globalAlpha = 1.0;
  }

  /**
   * 绘制 28 星宿
   */
  private drawStars(ctx: CanvasRenderingContext2D, centerX: number, centerY: number, radius: number) {
    const angleStep = (Math.PI * 2) / 28;
    const startAngle = -Math.PI / 2; // 从顶部开始

    for (let i = 0; i < this.stars.length; i++) {
      const star = this.stars[i];
      const angle = startAngle + i * angleStep;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      // 判断星宿所属星垣
      const color = this.getStarColor(i);
      
      // 判断是否为用户主星
      const isUserStar = star === this.currentUserStar;
      const isSelected = star === this.selectedStar;

      // 绘制星宿点
      ctx.beginPath();
      ctx.arc(x, y, isUserStar ? 8 : (isSelected ? 6 : 4), 0, Math.PI * 2);
      ctx.fillStyle = color;
      ctx.fill();

      // 用户主星加光晕效果
      if (isUserStar) {
        ctx.beginPath();
        ctx.arc(x, y, 12, 0, Math.PI * 2);
        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.globalAlpha = 0.5;
        ctx.stroke();
        ctx.globalAlpha = 1.0;
      }

      // 选中星宿加边框
      if (isSelected) {
        ctx.beginPath();
        ctx.arc(x, y, 10, 0, Math.PI * 2);
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.stroke();
      }

      // 绘制星宿名称
      ctx.font = '12px sans-serif';
      ctx.fillStyle = isUserStar ? '#D4AF37' : '#FFFFFF';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      
      // 计算文字偏移（让文字在圆外侧）
      const textRadius = radius + 20;
      const textX = centerX + textRadius * Math.cos(angle);
      const textY = centerY + textRadius * Math.sin(angle);
      
      ctx.fillText(star, textX, textY);
    }
  }

  /**
   * 绘制中心标记
   */
  private drawCenterMark(ctx: CanvasRenderingContext2D, centerX: number, centerY: number) {
    // 绘制中心圆点
    ctx.beginPath();
    ctx.arc(centerX, centerY, 3, 0, Math.PI * 2);
    ctx.fillStyle = '#D4AF37';
    ctx.fill();

    // 绘制中心文字
    ctx.font = '14px sans-serif';
    ctx.fillStyle = '#D4AF37';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    ctx.fillText('天极', centerX, centerY + 10);
  }

  /**
   * 获取星宿颜色（根据所属星垣）
   */
  private getStarColor(index: number): string {
    if (index < 7) return this.colors.east;      // 东方青龙
    if (index < 14) return this.colors.north;    // 北方玄武
    if (index < 21) return this.colors.west;     // 西方白虎
    return this.colors.south;                     // 南方朱雀
  }

  /**
   * 处理 Canvas 点击事件
   */
  private async handleCanvasTouch(touchX: number, touchY: number) {
    const centerX = this.canvasWidth / 2;
    const centerY = this.canvasHeight / 2;
    const radius = Math.min(centerX, centerY) * 0.75;
    const angleStep = (Math.PI * 2) / 28;
    const startAngle = -Math.PI / 2;

    // 检测点击的星宿
    for (let i = 0; i < this.stars.length; i++) {
      const angle = startAngle + i * angleStep;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      const distance = Math.sqrt(Math.pow(touchX - x, 2) + Math.pow(touchY - y, 2));
      
      if (distance < 15) {
        this.selectedStar = this.stars[i];
        this.selectedStarDetail = await this.logicEngine.getStarDetail(this.stars[i]);
        this.drawStarMap(); // 重绘以显示选中状态
        break;
      }
    }
  }
}
