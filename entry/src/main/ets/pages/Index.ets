import { router } from '@kit.ArkUI';
import { AchievementManager } from '../utils/AchievementManager';

@Entry
@Component
struct Index {
  @State studyProgress: number = 0;
  @State unlockedCount: number = 0;
  @State dailyTaskCoord: string = '1988-08-08 辰时';
  private achievementManager: AchievementManager = AchievementManager.getInstance();

  onPageShow() {
    this.studyProgress = this.achievementManager.getProgress();
    this.unlockedCount = this.achievementManager.getUnlockedCount();
  }

  build() {
    Scroll() {
      Column() {
      // 顶部研习进度区域 (游戏化元素)
      Row() {
        Column() {
          Text(this.unlockedCount >= 28 ? '研习等级：大成宗师' : '研习等级：初窥门径')
            .fontSize(14)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Medium)
          Progress({ value: this.studyProgress, total: 100, type: ProgressType.Linear })
            .width(150)
            .color('#D4AF37')
            .backgroundColor('#34495E')
            .height(6)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        if (this.unlockedCount >= 28) {
          // 勋章展示
          Column() {
            Image($r('sys.symbol.sun_max_fill'))
              .width(24)
              .height(24)
              .fillColor('#D4AF37')
            Text('大成印记')
              .fontSize(10)
              .fontColor('#D4AF37')
          }
        } else {
          Column() {
            Text(`已点亮: ${this.unlockedCount}/28`)
              .fontSize(12)
              .fontColor('#E8E8E8')
              .opacity(0.8)
          }
        }
      }
      .width('90%')
      .padding({ top: 20, bottom: 10 })

      // 顶部标题区域
      Column() {
        Text('禽星研习录')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D4AF37')
          .margin({ top: 20, bottom: 10 })
        
        Text('中华二十八宿逻辑推演 · 时空模拟研习')
          .fontSize(14)
          .fontColor('#8B7355')
          .opacity(0.8)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 每日研习任务卡片
      Column() {
        Row() {
          Image($r('sys.symbol.calendar_badge_clock'))
            .width(20)
            .height(20)
            .fillColor('#D4AF37')
            .margin({ right: 8 })
          Text('每日时空解析练习')
            .fontSize(16)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .margin({ bottom: 10 })

        Text(`当日随机坐标：${this.dailyTaskCoord}`)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .margin({ bottom: 12 })

        Button('前往解析')
          .width(100)
          .height(32)
          .fontSize(12)
          .backgroundColor('#D4AF37')
          .onClick(() => {
            router.pushUrl({ url: 'pages/BirthInput' });
          })
      }
      .width('90%')
      .padding(16)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(12)
      .margin({ top: 20 })
      .alignItems(HorizontalAlign.Start)

      // 主要功能区域
      Column() {
        // 排盘功能卡片
        this.FunctionCard(
          '时空建模',
          '输入历史时空坐标，生成逻辑基盘',
          '#2C3E50',
          () => {
            router.pushUrl({ url: 'pages/BirthInput' });
          }
        )
    
        // 流年运势卡片
        this.FunctionCard(
          '周期模拟',
          '动态模拟时空周期对个体的逻辑反馈',
          '#34495E',
          () => {
            router.pushUrl({ url: 'pages/CycleSimulation' });
          }
        )
    
        // 吞啈查询卡片
        this.FunctionCard(
          '宿星生态',
          '研习二十八宿间的生态克制关系逻辑',
          '#2C3E50',
          () => {
            router.pushUrl({ url: 'pages/StarEcology' });
          }
        )
    
        // 化道环境卡片
        this.FunctionCard(
          '环境变量',
          '解析干支化象与地理环境的交互影响',
          '#34495E',
          () => {
            router.pushUrl({ url: 'pages/EnvironmentalVariables' });
          }
        )
    
        // 星宿全景图卡片
        this.FunctionCard(
          '星宿全景',
          '探索二十八宿轨迹图谱，感受宇宙星象之美',
          '#2C3E50',
          () => {
            router.pushUrl({ url: 'pages/StarsPanorama' });
          }
        )
      }
      .width('90%')
      .margin({ top: 30, bottom: 30 })

      // 底部装饰
      Row() {
        Text('· · ·')
          .fontSize(20)
          .fontColor('#8B7355')
          .opacity(0.5)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 30 })
    }
    .width('100%')
    .backgroundImage($r('app.media.yanqin_tong_background_vertical'))
    .backgroundImageSize(ImageSize.Cover)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  FunctionCard(
    title: string,
    description: string,
    bgColor: string,
    onClick: () => void
  ) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })
      
      Text(description)
        .fontSize(14)
        .fontColor('#E8E8E8')
        .opacity(0.8)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(bgColor)
    .borderRadius(12)
    .margin({ bottom: 16 })
    .shadow({
      radius: 10,
      color: '#00000030',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(onClick)
  }
}
