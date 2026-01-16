import { router } from '@kit.ArkUI';
import { DeductionResult, StarNode } from '../utils/YanqinLogicEngine';

@Entry
@Component
struct LogicModelResult {
  @State result: DeductionResult | null = null;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear() {
    const params = router.getParams() as Record<string, DeductionResult>;
    if (params && params.result) {
      this.result = params.result;
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
          .onClick(() => router.back())
        Text('时空推演报告')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2C3E50')

      Scroll() {
        Column() {
          if (this.result) {
            // 1. 星宿运行轨迹可视化组件
            this.StarTrajectoryComponent()

            // 2. 推演逻辑链条
            this.LogicChainComponent()

            // 3. 环境变量分析
            this.EnvironmentalAnalysisComponent()

            // 4. 研习结论
            this.SummaryComponent()
          } else {
            Text('模型加载中...')
              .fontColor('#FFFFFF')
              .margin(50)
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.yanqin_tong_background_vertical'))
    .backgroundImageSize(ImageSize.Cover)
  }

  @Builder
  StarTrajectoryComponent() {
    Column() {
      Text('时空星宿映射图')
        .fontSize(16)
        .fontColor('#D4AF37')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Canvas(this.context)
        .width('100%')
        .height(260)
        .onReady(() => {
          this.drawStarChart();
        })
      
      Row() {
        Text(`当前主星：${this.result?.originStar.name}宿`)
          .fontSize(14)
          .fontColor('#FFFFFF')
        Blank()
        Text(`所属星垣：${this.result?.originStar.category}`)
          .fontSize(14)
          .fontColor('#E8E8E8')
          .opacity(0.8)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(44, 62, 80, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  LogicChainComponent() {
    Column() {
      Text('推演逻辑链条')
        .fontSize(16)
        .fontColor('#D4AF37')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Column() {
        ForEach(this.result?.logicSteps || [], (step: string) => {
          Row() {
            Circle({ width: 8, height: 8 }).fill('#D4AF37').margin({ right: 12 })
            Text(step)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .layoutWeight(1)
          }
          .margin({ bottom: 12 })
          .alignItems(VerticalAlign.Center)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(52, 73, 94, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  EnvironmentalAnalysisComponent() {
    Column() {
      Text('环境变量逻辑反馈')
        .fontSize(16)
        .fontColor('#D4AF37')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text(this.result?.environmentalImpact || '')
        .fontSize(14)
        .fontColor('#E8E8E8')
        .lineHeight(22)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(44, 62, 80, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  SummaryComponent() {
    Column() {
      Text('研习能级评估')
        .fontSize(16)
        .fontColor('#D4AF37')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        Gauge({ value: this.result?.energyLevel || 0, min: 0, max: 100 })
          .width(100)
          .height(100)
          .colors([[0xD4AF37, 1.0], [0x34495E, 0.5]])
          .strokeWidth(10)
        
        Column() {
          Text(`${this.result?.energyLevel}%`)
            .fontSize(24)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Bold)
          Text('逻辑协调能级')
            .fontSize(12)
            .fontColor('#E8E8E8')
            .opacity(0.8)
        }
        .margin({ left: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(52, 73, 94, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  private drawStarChart() {
    const centerX = 150;
    const centerY = 130;
    const radius = 100;

    this.context.clearRect(0, 0, 400, 300);
    
    // 绘制轨道
    this.context.beginPath();
    this.context.arc(centerX, centerY, radius, 0, Math.PI * 2);
    this.context.strokeStyle = 'rgba(212, 175, 55, 0.2)';
    this.context.lineWidth = 1;
    this.context.stroke();

    // 绘制 28 星宿点
    for (let i = 0; i < 28; i++) {
      const angle = (i * Math.PI * 2) / 28;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      const isMainStar = i === this.result?.originStar.position;
      
      this.context.beginPath();
      this.context.arc(x, y, isMainStar ? 5 : 2, 0, Math.PI * 2);
      this.context.fillStyle = isMainStar ? '#D4AF37' : 'rgba(255, 255, 255, 0.5)';
      this.context.fill();

      if (isMainStar) {
        // 绘制高亮光晕
        this.context.shadowBlur = 10;
        this.context.shadowColor = '#D4AF37';
        this.context.stroke();
        this.context.shadowBlur = 0;
      }
    }

    // 绘制中心原点
    this.context.beginPath();
    this.context.arc(centerX, centerY, 5, 0, Math.PI * 2);
    this.context.fillStyle = '#FFFFFF';
    this.context.fill();
  }
}
