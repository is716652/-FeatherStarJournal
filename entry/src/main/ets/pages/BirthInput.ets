import { router } from '@kit.ArkUI';
import { LunarCalendar, CalendarData } from '../utils/LunarCalendar';
import { YanqinLogicEngine } from '../utils/YanqinLogicEngine';

@Entry
@Component
struct BirthInput {
  @State selectedYear: number = 2000;
  @State selectedMonth: number = 1;
  @State selectedDay: number = 1;
  @State selectedHour: number = 0;
  @State lunarDate: string = '查询中...';
  @State showDatePicker: boolean = false;
  @State showTimePicker: boolean = false;
  @State currentDateData: CalendarData | null = null;
  
  private lunarCalendar: LunarCalendar = LunarCalendar.getInstance();
  private logicEngine: YanqinLogicEngine = YanqinLogicEngine.getInstance();

  async aboutToAppear(): Promise<void> {
    // 初始化万年历
    await this.lunarCalendar.init(getContext(this));
    // 初始化时查询农历
    await this.updateLunarDate();
  }

  // 时辰列表（12时辰）
  private timeList: string[] = [
    '子时 (23:00-01:00)', '丑时 (01:00-03:00)', '寅时 (03:00-05:00)',
    '卯时 (05:00-07:00)', '辰时 (07:00-09:00)', '巳时 (09:00-11:00)',
    '午时 (11:00-13:00)', '未时 (13:00-15:00)', '申时 (15:00-17:00)',
    '酉时 (17:00-19:00)', '戌时 (19:00-21:00)', '亥时 (21:00-23:00)'
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('sys.symbol.chevron_left'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/Index' }, router.RouterMode.Single);
          })

        Text('时空建模')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#2C3E50')

      // 主内容区域
      Scroll() {
        Column() {
          // 标题提示
          Column() {
            Text('设定研习时空原点')
              .fontSize(24)
              .fontColor('#D4AF37')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })

            Text('精确的时空参数是构建演禽逻辑模型的基础')
              .fontSize(14)
              .fontColor('#8B7355')
              .opacity(0.8)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 24, bottom: 32 })

          // 公历日期选择卡片
          this.DateCard()

          // 时辰选择卡片
          this.TimeCard()

          // 农历显示卡片
          this.LunarCard()

          // 底部按钮
          Button('构建逻辑模型')
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor('#D4AF37')
            .borderRadius(25)
            .margin({ top: 40, bottom: 30 })
            .onClick(async () => {
              if (this.currentDateData) {
                // 执行推演逻辑 (异步)
                const result = await this.logicEngine.deduce(this.currentDateData, this.selectedHour);
                // 跳转到结果页并传递推演结果
                router.pushUrl({
                  url: 'pages/LogicModelResult',
                  params: { result: result }
                });
              } else {
                console.warn('时空数据未就绪，无法推演');
              }
            })
        }
        .width('90%')
        .padding({ top: 10, bottom: 10 })
      }
      .layoutWeight(1)
      .width('100%')
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.yanqin_tong_background_vertical'))
    .backgroundImageSize(ImageSize.Cover)
  }

  @Builder
  DateCard() {
    Column() {
      Row() {
        Text('坐标日期 (公历)')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 日期输入行
      Row() {
        // 年份
        Column() {
          TextInput({ text: this.selectedYear.toString() })
            .width(80)
            .height(50)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .fontColor('#2C3E50')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => {
              const year = parseInt(value);
              if (!isNaN(year) && year >= 1900 && year <= 2061) {
                this.selectedYear = year;
                this.updateLunarDate();
              }
            })
          Text('年')
            .fontSize(14)
            .fontColor('#E8E8E8')
            .margin({ top: 4 })
        }

        Text('-')
          .fontSize(20)
          .fontColor('#E8E8E8')
          .margin({ left: 8, right: 8 })

        // 月份
        Column() {
          TextInput({ text: this.selectedMonth.toString() })
            .width(60)
            .height(50)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .fontColor('#2C3E50')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => {
              const month = parseInt(value);
              if (!isNaN(month) && month >= 1 && month <= 12) {
                this.selectedMonth = month;
                this.updateLunarDate();
              }
            })
          Text('月')
            .fontSize(14)
            .fontColor('#E8E8E8')
            .margin({ top: 4 })
        }

        Text('-')
          .fontSize(20)
          .fontColor('#E8E8E8')
          .margin({ left: 8, right: 8 })

        // 日
        Column() {
          TextInput({ text: this.selectedDay.toString() })
            .width(60)
            .height(50)
            .fontSize(18)
            .textAlign(TextAlign.Center)
            .fontColor('#2C3E50')
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .type(InputType.Number)
            .onChange((value: string) => {
              const day = parseInt(value);
              if (!isNaN(day) && day >= 1 && day <= 31) {
                this.selectedDay = day;
                this.updateLunarDate();
              }
            })
          Text('日')
            .fontSize(14)
            .fontColor('#E8E8E8')
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 日期选择按钮
      Button('选择日期')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#2C3E50')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick(() => {
          this.showDatePicker = true;
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(44, 62, 80, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  TimeCard() {
    Column() {
      Row() {
        Text('坐标时辰')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 时辰显示
      Text(this.timeList[this.selectedHour])
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontColor('#2C3E50')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .textAlign(TextAlign.Center)
        .padding({ top: 12 })

      // 时辰选择网格
      Grid() {
        ForEach(this.timeList, (time: string, index: number) => {
          GridItem() {
            Text(time.split(' ')[0])
              .width('100%')
              .height(44)
              .fontSize(14)
              .fontColor(this.selectedHour === index ? '#FFFFFF' : '#2C3E50')
              .backgroundColor(this.selectedHour === index ? '#D4AF37' : '#FFFFFF')
              .borderRadius(8)
              .textAlign(TextAlign.Center)
              .padding({ top: 10 })
              .onClick(() => {
                this.selectedHour = index;
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
      .height(240)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(52, 73, 94, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  LunarCard() {
    Column() {
      Row() {
        Text('对应农历')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text(this.lunarDate)
            .fontSize(20)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 4 })

          Text('（从万年历自动查询）')
            .fontSize(12)
            .fontColor('#8B7355')
            .opacity(0.7)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(80)
      .padding(16)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .borderRadius(8)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(44, 62, 80, 0.9)')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  // 更新农历日期（从万年历JSON数据中查询）
  private async updateLunarDate(): Promise<void> {
    try {
      this.lunarDate = '查询中...';
      
      const dateData = await this.lunarCalendar.getDateInfo(
        this.selectedYear,
        this.selectedMonth,
        this.selectedDay
      );
      
      if (dateData) {
        this.currentDateData = dateData;
        this.lunarDate = LunarCalendar.getFullLunarString(dateData);
      } else {
        this.lunarDate = '未找到对应农历日期';
      }
    } catch (err) {
      console.error('查询农历日期失败:', err);
      this.lunarDate = '查询失败，请检查日期';
    }
  }
}
