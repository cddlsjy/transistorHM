/**
 * SettingsPage.ets
 * Settings page for app configuration
 */

import router from '@ohos.router';
import PreferencesHelper, { 
  THEME_LIGHT, 
  THEME_DARK, 
  THEME_SYSTEM 
} from '../helpers/PreferencesHelper';

@Entry
@Component
struct SettingsPage {
  @State private themeSelection: number = THEME_SYSTEM;
  @State private editStationsEnabled: boolean = false;
  @State private tapAnywherePlayback: boolean = false;
  @State private editStreamUrisEnabled: boolean = false;

  aboutToAppear() {
    this.loadSettings();
  }

  loadSettings() {
    this.themeSelection = PreferencesHelper.loadThemeSelection();
    this.editStationsEnabled = PreferencesHelper.loadEditStationsEnabled();
    this.tapAnywherePlayback = PreferencesHelper.loadTapAnyWherePlayback();
    this.editStreamUrisEnabled = PreferencesHelper.loadEditStreamUrisEnabled();
  }

  handleThemeChange(theme: number) {
    this.themeSelection = theme;
    PreferencesHelper.saveThemeSelection(theme);
  }

  handleEditStationsChange(enabled: boolean) {
    this.editStationsEnabled = enabled;
    PreferencesHelper.saveEditStationsEnabled(enabled);
  }

  handleTapAnywhereChange(enabled: boolean) {
    this.tapAnywherePlayback = enabled;
    // Save via direct implementation
  }

  build() {
    Column() {
      // Header
      Row() {
        Button('< Back')
          .onClick(() => router.back())
        Text('Settings')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')

      ScrollView() {
        Column() {
          // Appearance section
          Text('Appearance')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .padding({ left: 16, top: 16, bottom: 8 })

          Column() {
            Text('Theme')
              .fontSize(16)
              .width('100%')
              .padding(16)
            
            Row() {
              Radio({ value: 'light', group: 'theme' })
                .checked(this.themeSelection === THEME_LIGHT)
                .onChange((isChecked) => {
                  if (isChecked) this.handleThemeChange(THEME_LIGHT);
                })
              Text('Light')
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16 })

            Row() {
              Radio({ value: 'dark', group: 'theme' })
                .checked(this.themeSelection === THEME_DARK)
                .onChange((isChecked) => {
                  if (isChecked) this.handleThemeChange(THEME_DARK);
                })
              Text('Dark')
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16 })

            Row() {
              Radio({ value: 'system', group: 'theme' })
                .checked(this.themeSelection === THEME_SYSTEM)
                .onChange((isChecked) => {
                  if (isChecked) this.handleThemeChange(THEME_SYSTEM);
                })
              Text('System')
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .margin({ left: 16, right: 16 })

          // Playback section
          Text('Playback')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .padding({ left: 16, top: 24, bottom: 8 })

          Column() {
            Row() {
              Column() {
                Text('Edit Stations')
                  .fontSize(16)
                Text('Long press to edit station details')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              
              Toggle({ type: ToggleType.Switch, isOn: this.editStationsEnabled })
                .onChange((isOn) => this.handleEditStationsChange(isOn))
            }
            .width('100%')
            .padding(16)

            Divider()
              .padding({ left: 16, right: 16 })

            Row() {
              Column() {
                Text('Tap Anywhere to Play')
                  .fontSize(16)
                Text('Tap station to start playback')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .layoutWeight(1)
              
              Toggle({ type: ToggleType.Switch, isOn: this.tapAnywherePlayback })
                .onChange((isOn) => this.handleTapAnywhereChange(isOn))
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .margin({ left: 16, right: 16 })

          // About section
          Text('About')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .padding({ left: 16, top: 24, bottom: 8 })

          Column() {
            Text('Transistor')
              .fontSize(16)
              .width('100%')
              .padding(16)
            
            Text('Version 4.2.6')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 16, bottom: 16 })
            
            Text('Simple Radio App for listening to radio programs over the internet.')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
              .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .margin({ left: 16, right: 16, bottom: 32 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
