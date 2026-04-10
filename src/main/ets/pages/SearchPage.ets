/**
 * SearchPage.ets
 * Search and add radio stations
 */

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Station } from '../models/Station';
import { v4 as uuidv4 } from '../utils/uuid';
import CollectionHelper from '../helpers/CollectionHelper';
import NetworkHelper, { parseM3UPlaylist, parsePLSPlaylist } from '../helpers/NetworkHelper';

@Entry
@Component
struct SearchPage {
  @State private searchQuery: string = '';
  @State private manualUrl: string = '';
  @State private isLoading: boolean = false;
  @State private showManualInput: boolean = false;
  
  private context = getContext(this);

  async handleAddStation() {
    if (!this.searchQuery.trim()) {
      promptAction.showToast({ message: 'Please enter a station name or URL' });
      return;
    }

    this.isLoading = true;

    try {
      // Check if it's a direct URL
      if (this.searchQuery.startsWith('http://') || this.searchQuery.startsWith('https://')) {
        await this.addStationFromUrl(this.searchQuery);
      } else {
        // Search for stations
        promptAction.showToast({ message: 'Searching stations by name is not implemented. Please enter a direct URL.' });
      }
    } catch (e) {
      promptAction.showToast({ message: 'Failed to add station: ' + (e.message || 'Unknown error') });
    }

    this.isLoading = false;
  }

  async addStationFromUrl(url: string) {
    try {
      // Detect content type
      const contentType = NetworkHelper.detectContentTypeSync(url);
      
      // Fetch content if it's a playlist
      let streamUrl = url;
      
      if (url.includes('.m3u') || url.includes('.m3u8') || url.includes('.pls')) {
        const content = await NetworkHelper.fetch(url);
        if (url.includes('.m3u') || url.includes('.m3u8')) {
          const urls = parseM3UPlaylist(content);
          if (urls.length > 0) {
            streamUrl = urls[0];
          }
        } else if (url.includes('.pls')) {
          const urls = parsePLSPlaylist(content);
          if (urls.length > 0) {
            streamUrl = urls[0];
          }
        }
      }

      // Create station
      const station = new Station(
        uuidv4(),
        false,
        this.extractStationName(streamUrl),
        false,
        [streamUrl],
        0,
        contentType,
        '',
        '',
        '',
        -1,
        false,
        '',
        url,
        new Date(),
        false,
        '',
        '',
        0,
        ''
      );

      // Add to collection
      CollectionHelper.addStation(this.context, station);
      promptAction.showToast({ message: 'Station added successfully' });
      router.back();
    } catch (e) {
      throw new Error('Invalid station URL');
    }
  }

  extractStationName(url: string): string {
    try {
      const urlObj = new URL(url);
      return urlObj.hostname.replace('www.', '');
    } catch (e) {
      return 'Unknown Station';
    }
  }

  handleToggleInputMode() {
    this.showManualInput = !this.showManualInput;
  }

  build() {
    Column() {
      // Header
      Row() {
        Button('< Back')
          .onClick(() => router.back())
        Text('Add Station')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')

      Column() {
        Text('Enter a radio stream URL (MP3, AAC, OGG, or HLS)')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })

        // Search input
        TextInput({ placeholder: 'Stream URL or M3U/PLS playlist URL' })
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#E0E0E0' })
          .margin({ left: 16, right: 16 })
          .onChange((value) => {
            this.searchQuery = value;
          })

        // Loading indicator
        if (this.isLoading) {
          Row() {
            LoadingProgress()
              .width(24)
              .height(24)
            Text('Adding station...')
              .margin({ left: 8 })
          }
          .padding(16)
        }

        // Add button
        Button('Add Station')
          .width('100%')
          .height(48)
          .margin({ left: 16, right: 16, top: 16 })
          .enabled(!this.isLoading && !!this.searchQuery.trim())
          .onClick(() => this.handleAddStation())

        // Help text
        Column() {
          Text('Supported formats:')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
          
          Text('• Direct stream URLs (MP3, AAC, OGG)')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
          
          Text('• M3U and M3U8 playlists')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
          
          Text('• PLS playlists')
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .margin({ top: 24 })

        // Example URLs
        Column() {
          Text('Example URLs:')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ bottom: 8 })
          
          Text('http://stream.example.com/radio.mp3')
            .fontSize(12)
            .fontColor('#666666')
            .width('100%')
          
          Text('https://radio.example.com/listen.pls')
            .fontSize(12)
            .fontColor('#666666')
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .margin({ left: 16, right: 16, top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
