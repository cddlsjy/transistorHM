/**
 * Index.ets
 * Main page - Station list
 * Converted from Android/Kotlin to ArkUI
 */

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Collection } from '../models/Collection';
import { Station } from '../models/Station';
import CollectionHelper from '../helpers/CollectionHelper';
import playerService, { PlayerState } from '../services/PlayerService';
import PreferencesHelper from '../helpers/PreferencesHelper';

@Entry
@Component
struct Index {
  @State private stations: Station[] = [];
  @State private isLoading: boolean = true;
  @State private currentPlayingUuid: string = '';
  @State private playerState: PlayerState = PlayerState.IDLE;
  
  private context = getContext(this);

  aboutToAppear() {
    PreferencesHelper.init(this.context);
    this.loadCollection();
    
    playerService.registerCallback({
      onPlaybackStateChanged: (state) => {
        this.playerState = state;
      },
      onError: (error) => {
        promptAction.showToast({ message: error });
      },
      onStationChanged: (station) => {
        this.currentPlayingUuid = station.uuid;
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

  loadCollection() {
    try {
      this.isLoading = true;
      const collection = CollectionHelper.loadCollection(this.context);
      this.stations = collection.stations;
      this.isLoading = false;
    } catch (e) {
      console.error('Error loading collection: ' + JSON.stringify(e));
      this.isLoading = false;
    }
  }

  async handlePlayStation(station: Station) {
    if (this.currentPlayingUuid === station.uuid && playerService.isPlaying()) {
      await playerService.stop();
      this.currentPlayingUuid = '';
    } else {
      await playerService.play(station);
      this.currentPlayingUuid = station.uuid;
    }
  }

  handleAddStation() {
    router.pushUrl({ url: 'pages/SearchPage' });
  }

  handleSettings() {
    router.pushUrl({ url: 'pages/SettingsPage' });
  }

  handleDeleteStation(station: Station) {
    try {
      CollectionHelper.deleteStation(this.context, station);
      this.loadCollection();
      promptAction.showToast({ message: 'Station deleted' });
    } catch (e) {
      promptAction.showToast({ message: 'Failed to delete station' });
    }
  }

  handleStarStation(station: Station) {
    station.starred = !station.starred;
    try {
      CollectionHelper.saveCollection(this.context, new Collection(this.stations));
      this.stations = CollectionHelper.loadCollection(this.context).stations;
    } catch (e) {
      console.error('Error starring station: ' + JSON.stringify(e));
    }
  }

  build() {
    Column() {
      Row() {
        Text('Transistor')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16 })
        Blank()
        Button('Settings')
          .onClick(() => this.handleSettings())
          .margin({ right: 8 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#F5F5F5')

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
          Text('Loading...')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.stations.length === 0) {
        Column() {
          Text('No stations')
            .fontSize(18)
            .fontColor('#666666')
          Button('+ Add Station')
            .margin({ top: 16 })
            .onClick(() => this.handleAddStation())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.stations, (station: Station) => {
            ListItem() {
              this.StationCard(station)
            }
          })
          ListItem() {
            Button('+ Add Station')
              .width('100%')
              .height(64)
              .onClick(() => this.handleAddStation())
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.currentPlayingUuid) {
        this.MiniPlayerBar()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StationCard(station: Station) {
    Row() {
      Column() {
        Text(station.name.charAt(0).toUpperCase())
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(48)
          .height(48)
          .backgroundColor(station.imageColor !== -1 ? '#' + station.imageColor.toString(16) : '#6200EE')
          .borderRadius(8)
          .textAlign(TextAlign.Center)
      }
      .width(48)
      .height(48)
      .margin({ right: 12 })

      Column() {
        Text(station.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (station.bitrate > 0) {
          Text(station.bitrate + ' kbps')
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (station.starred) {
        Text('*')
          .fontSize(24)
          .fontColor('#FFC107')
          .onClick(() => this.handleStarStation(station))
      }

      Button() {
        Text(this.currentPlayingUuid === station.uuid && playerService.isPlaying() ? '||' : '>')
          .fontSize(20)
      }
      .type(ButtonType.Normal)
      .backgroundColor('transparent')
      .onClick(() => this.handlePlayStation(station))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .onLongPress(() => this.handleDeleteStation(station))
  }

  @Builder
  MiniPlayerBar() {
    Row() {
      const currentStation = this.stations.find(s => s.uuid === this.currentPlayingUuid);
      if (currentStation) {
        Text(currentStation.name)
          .fontSize(14)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Button() {
          Text('X')
            .fontSize(16)
        }
        .type(ButtonType.Normal)
        .backgroundColor('transparent')
        .onClick(() => {
          playerService.stop();
          this.currentPlayingUuid = '';
        })
      }
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#6200EE')
    .onClick(() => router.pushUrl({ url: 'pages/PlayerPage' }))
  }
}
