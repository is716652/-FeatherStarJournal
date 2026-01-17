import { router } from '@kit.ArkUI';
import { YanqinLogicEngine } from '../utils/YanqinLogicEngine';
import { AchievementManager } from '../utils/AchievementManager';

@Entry
@Component
struct StarEcology {
  @State selectedStar: string = '角';
  @State ecologyRelations: string[] = [];
  private logicEngine: YanqinLogicEngine = YanqinLogicEngine.getInstance();
  private achievementManager: AchievementManager = AchievementManager.getInstance();
  private stars: string[] = [
    '角', '亢', '氐', '房', '心', '尾', '箕',
    '斗', '牛', '女', '虚', '危', '室', '壁',
    '奎', '娄', '胃', '昴', '毕', '觜', '参',
    '井', '鬼', '柳', '星', '张', '翼', '轸'
  ];

  async aboutToAppear() {
    // 初始加载默认星宿的生态关系
    await this.loadEcologyData();
  }

  private async loadEcologyData() {
    this.ecologyRelations = await this.logicEngine.getEcologyRelation(this.selectedStar);
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
        Text('宿星生态研习')
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
          // 1. 星宿选择网格
          Column() {
            Text('请选择研习宿星')
              .fontSize(16)
              .fontColor('#D4AF37')
              .margin({ bottom: 12 })
            
            Grid() {
              ForEach(this.stars, (star: string) => {
                GridItem() {
                  Text(star)
                    .width('100%')
                    .height(40)
                    .fontSize(14)
                    .fontColor(this.selectedStar === star ? '#FFFFFF' : '#2C3E50')
                    .backgroundColor(this.selectedStar === star ? '#D4AF37' : '#FFFFFF')
                    .borderRadius(8)
                    .textAlign(TextAlign.Center)
                    .onClick(async () => {
                      this.selectedStar = star;
                      this.achievementManager.unlockStar(star);
                      await this.loadEcologyData();
                    })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .width('100%')
            .height(200)
          }
          .padding(20)
          .backgroundColor('rgba(44, 62, 80, 0.9)')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 2. 生态链展示
          Column() {
            Text(`${this.selectedStar}宿 · 生态逻辑链`)
              .fontSize(18)
              .fontColor('#D4AF37')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 })

            Row() {
              // 吞
              Column() {
                Text('向上兼容 (吞)')
                  .fontSize(12)
                  .fontColor('#E8E8E8')
                  .margin({ bottom: 8 })
                ForEach(this.ecologyRelations, (rel: string) => {
                  if (rel.startsWith('吞')) {
                    Text(rel.split('：')[1])
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                      .padding(10)
                      .backgroundColor('#27AE60')
                      .borderRadius(8)
                  }
                })
              }
              .layoutWeight(1)

              Text('↔')
                .fontSize(30)
                .fontColor('#D4AF37')
                .width(40)
                .textAlign(TextAlign.Center)

              // 啖
              Column() {
                Text('向下覆盖 (啖)')
                  .fontSize(12)
                  .fontColor('#E8E8E8')
                  .margin({ bottom: 8 })
                ForEach(this.ecologyRelations, (rel: string) => {
                  if (rel.startsWith('啖')) {
                    Text(rel.split('：')[1])
                      .fontSize(16)
                      .fontColor('#FFFFFF')
                      .padding(10)
                      .backgroundColor('#C0392B')
                      .borderRadius(8)
                  }
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
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
            Text('吞啖逻辑反映了星宿间的能量捕食与被捕食关系。在推演中，若主星处于被覆盖位置，其逻辑能级将受到显著干扰。')
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
