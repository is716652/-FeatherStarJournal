import { router } from '@kit.ArkUI';
import { YanqinLogicEngine } from '../utils/YanqinLogicEngine';

@Entry
@Component
struct EnvironmentalVariables {
  @State selectedGan: string = '甲';
  @State selectedZhi: string = '子';
  private logicEngine: YanqinLogicEngine = YanqinLogicEngine.getInstance();
  
  private gans: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
  private zhis: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
          .onClick(() => router.back())
        Text('环境变量研习')
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
          // 1. 干支参数设定
          Column() {
            Text('设定研习环境变量参数')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 16 })
            
            Row() {
              // 天干选择
              List() {
                ForEach(this.gans, (gan: string) => {
                  ListItem() {
                    Text(gan)
                      .width(40)
                      .height(40)
                      .fontSize(16)
                      .fontColor(this.selectedGan === gan ? '#FFFFFF' : '#D4AF37')
                      .backgroundColor(this.selectedGan === gan ? '#D4AF37' : 'rgba(255, 255, 255, 0.1)')
                      .borderRadius(20)
                      .textAlign(TextAlign.Center)
                      .onClick(() => this.selectedGan = gan)
                  }
                  .margin({ bottom: 8 })
                })
              }
              .width(50)
              .height(200)

              Blank()

              // 地支选择
              Grid() {
                ForEach(this.zhis, (zhi: string) => {
                  GridItem() {
                    Text(zhi)
                      .width(44)
                      .height(44)
                      .fontSize(16)
                      .fontColor(this.selectedZhi === zhi ? '#FFFFFF' : '#E8E8E8')
                      .backgroundColor(this.selectedZhi === zhi ? '#D4AF37' : 'rgba(255, 255, 255, 0.1)')
                      .borderRadius(8)
                      .textAlign(TextAlign.Center)
                      .onClick(() => this.selectedZhi = zhi)
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsGap(8)
              .columnsGap(8)
              .width(200)
              .height(200)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          }
          .padding(20)
          .backgroundColor('rgba(44, 62, 80, 0.9)')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 2. 环境化象解析
          Column() {
            Text(`${this.selectedGan}${this.selectedZhi} · 环境逻辑转化`)
              .fontSize(18)
              .fontColor('#D4AF37')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            Text(this.logicEngine.getEnvironmentalTransformation(this.selectedGan, this.selectedZhi))
              .fontSize(15)
              .fontColor('#FFFFFF')
              .lineHeight(24)
              .padding(16)
              .backgroundColor('rgba(255, 255, 255, 0.05)')
              .borderRadius(8)
          }
          .padding(20)
          .backgroundColor('rgba(52, 73, 94, 0.9)')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 3. 研习笔记
          Column() {
            Text('研习笔记')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 8 })
            Text('环境变量（化道）是指时空背景对宿星能量的影响。不同的干支组合会模拟出不同的背景力场，从而改变推演模型中的权重分配。')
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
}
