import { router } from '@kit.ArkUI';
import { YanqinLogicEngine, StarNode } from '../utils/YanqinLogicEngine';

@Entry
@Component
struct CycleSimulation {
  @State simulationYear: number = 2026;
  @State energyFlux: number = 0;
  @State feedback: string = '待模拟...';
  @State mockUserStar: StarNode = {
    name: '心',
    animal: '月狐',
    element: '月',
    position: 4,
    category: '东方青龙垣',
    fullName: '心月狐'
  };

  private logicEngine: YanqinLogicEngine = YanqinLogicEngine.getInstance();
  private years: number[] = [2024, 2025, 2026, 2027, 2028, 2029, 2030];

  aboutToAppear() {
    this.runSimulation();
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
        Text('周期能场模拟')
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
          // 1. 初始建模信息预览
          Column() {
            Row() {
              Text('初始时空模型：')
                .fontSize(14)
                .fontColor('#E8E8E8')
              Text(`${this.mockUserStar.fullName}`)
                .fontSize(14)
                .fontColor('#D4AF37')
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(255, 255, 255, 0.05)')
          .borderRadius(8)
          .margin({ bottom: 16 })

          // 2. 目标周期选择
          Column() {
            Text('设定模拟目标周期')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 16 })
            
            Row() {
              ForEach(this.years, (year: number) => {
                Button(year.toString())
                  .width(60)
                  .height(40)
                  .fontSize(14)
                  .fontColor(this.simulationYear === year ? '#FFFFFF' : '#D4AF37')
                  .backgroundColor(this.simulationYear === year ? '#D4AF37' : 'transparent')
                  .border({ width: 1, color: '#D4AF37' })
                  .borderRadius(8)
                  .onClick(() => {
                    this.simulationYear = year;
                    this.runSimulation();
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .padding(20)
          .backgroundColor('rgba(44, 62, 80, 0.9)')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 3. 能级波动可视化
          Column() {
            Text('周期逻辑干涉能级')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 20 })

            Stack() {
              Progress({ value: this.energyFlux, total: 100, type: ProgressType.Ring })
                .width(150)
                .height(150)
                .color('#D4AF37')
                .style({ strokeWidth: 15 })
              
              Column() {
                Text(`${this.energyFlux}%`)
                  .fontSize(30)
                  .fontColor('#D4AF37')
                  .fontWeight(FontWeight.Bold)
                Text('协同度')
                  .fontSize(12)
                  .fontColor('#E8E8E8')
              }
            }
            .margin({ bottom: 20 })

            Text(this.feedback)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .lineHeight(24)
              .textAlign(TextAlign.Center)
              .padding(16)
              .backgroundColor('rgba(255, 255, 255, 0.05)')
              .borderRadius(8)
          }
          .padding(20)
          .backgroundColor('rgba(52, 73, 94, 0.9)')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 4. 研习结论建议
          Column() {
            Text('研习建议')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 8 })
            Text('周期模拟揭示了外部环境规律对个人逻辑基盘的影响。在高协同度周期内，适合执行高能耗研习任务；在低协同度周期内，应减少系统变量输入，维持基盘稳定。')
              .fontSize(14)
              .fontColor('#E8E8E8')
              .lineHeight(20)
          }
          .padding(20)
          .backgroundColor('rgba(44, 62, 80, 0.9)')
          .borderRadius(12)
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

  private async runSimulation() {
    const result = await this.logicEngine.simulateCycle(this.mockUserStar, this.simulationYear);
    this.energyFlux = result.energyFlux;
    this.feedback = result.feedback;
  }
}
