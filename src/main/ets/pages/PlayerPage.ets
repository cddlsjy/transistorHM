/**
 * PlayerPage.ets
 * Player page with full playback controls
 */

import router from '@ohos.router';
import { Station } from '../models/Station';
import playerService, { PlayerState } from '../services/PlayerService';

@Entry
@Component
struct PlayerPage {
  @State private currentStation: Station = null;
  @State private playerState: PlayerState = PlayerState.IDLE;
  @State private isLoading: boolean = false;

  aboutToAppear() {
    this.currentStation = playerService.getCurrentStation();
    this.playerState = playerService.getState();
    
    playerService.registerCallback({
      onPlaybackStateChanged: (state) => {
        this.playerState = state;
        this.isLoading = state === PlayerState.LOADING;
      },
      onError: (error) => {
        console.error('Playback error: ' + error);
      },
      onStationChanged: (station) => {
        this.currentStation = station;
      }
    });
  }

  aboutToDisappear() {
    playerService.unregisterCallback({
      onPlaybackStateChanged: () => {},
      onError: () => {},
      onStationChanged: () => {}
    });
  }

  async handlePlayPause() {
    if (playerService.isPlaying()) {
      await playerService.pause();
    } else if (this.playerState === PlayerState.PAUSED) {
      await playerService.resume();
    }
  }

  async handleStop() {
    await playerService.stop();
    router.back();
  }

  build() {
    Column() {
      // Back button
      Row() {
        Button('< Back')
          .onClick(() => router.back())
      }
      .width('100%')
      .padding(16)

      Blank()

      // Station info
      Column() {
        // Station image/logo
        Column() {
          if (this.currentStation) {
            Text(this.currentStation.name.charAt(0).toUpperCase())
              .fontSize(72)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width(180)
              .height(180)
              .backgroundColor(this.currentStation.imageColor !== -1 
                ? '#' + this.currentStation.imageColor.toString(16) 
                : '#6200EE')
              .borderRadius(24)
              .textAlign(TextAlign.Center)
          } else {
            Text('?')
              .fontSize(72)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width(180)
              .height(180)
              .backgroundColor('#6200EE')
              .borderRadius(24)
              .textAlign(TextAlign.Center)
          }
        }

        // Station name
        if (this.currentStation) {
          Text(this.currentStation.name)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 32 })
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          if (this.currentStation.bitrate > 0) {
            Text(this.currentStation.bitrate + ' kbps')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 8 })
          }
        } else {
          Text('No station playing')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 32 })
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .padding({ left: 32, right: 32 })

      Blank()

      // Loading indicator
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(32)
            .height(32)
          Text('Loading...')
            .margin({ left: 8 })
        }
      }

      // Playback controls
      Row() {
        // Stop button
        Button() {
          Text('[]')
            .fontSize(24)
        }
        .type(ButtonType.Normal)
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#E0E0E0')
        .onClick(() => this.handleStop())
        .margin({ right: 32 })

        // Play/Pause button
        Button() {
          Text(this.playerState === PlayerState.PLAYING ? '||' : '>')
            .fontSize(32)
        }
        .type(ButtonType.Normal)
        .width(72)
        .height(72)
        .borderRadius(36)
        .backgroundColor('#6200EE')
        .onClick(() => this.handlePlayPause())
        .enabled(!!this.currentStation)
      }
      .margin({ bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
