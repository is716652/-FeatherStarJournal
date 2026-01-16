import { router } from '@kit.ArkUI';

@Entry
@Component
struct Splash {
  build() {
    Stack() {
      Image($r('app.media.yanqin_tong_background_vertical'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 简介与入口区域
      Column() {
        // 简介文字卡片
        Column() {
          Text('禽星，源于古代天文学之二十八宿。古人观测苍穹，将周天划分为二十八个区域，每宿对应一种灵禽，构建出宏大的宇宙生态逻辑。')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .lineHeight(24)
            .textAlign(TextAlign.Start)
            .margin({ bottom: 12 })

          Text('本研习录旨在通过数字推演，解析时空坐标与星宿运行之奥秘，传承中华传统数智文化。')
            .fontSize(16)
            .fontColor('#D4AF37')
            .lineHeight(24)
            .fontWeight(FontWeight.Medium)
        }
        .width('85%')
        .padding(24)
        .backgroundColor('rgba(0, 0, 0, 0.6)')
        .borderRadius(16)
        .margin({ bottom: 40 })

        // 进入链接
        Text('进入研习')
          .fontSize(20)
          .fontColor('#D4AF37')
          .fontWeight(FontWeight.Bold)
          .letterSpacing(2)
          .padding({ bottom: 4 })
          .border({ width: { bottom: 2 }, color: '#D4AF37' })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Index'
            }, router.RouterMode.Single).catch((err: Error) => {
              console.error('Failed to push url:', err.message);
            });
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
