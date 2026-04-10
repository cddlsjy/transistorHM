/**
 * PlayerService.ets
 * Handles audio playback using HarmonyOS AVPlayer
 * Converted from Android to HarmonyOS
 * Original: org.y20k.transistor.PlayerService & BasePlayerService
 */

import avPlayer from '@ohos.multimedia.avplayer';
import { Station } from '../models/Station';
import hilog from '@ohos.hilog';

const TAG = 'PlayerService';
const DOMAIN = 0x0002;

export enum PlayerState {
  IDLE = 'idle',
  LOADING = 'loading',
  PLAYING = 'playing',
  PAUSED = 'paused',
  STOPPED = 'stopped',
  ERROR = 'error'
}

export interface PlayerCallback {
  onPlaybackStateChanged(state: PlayerState): void;
  onError(error: string): void;
  onStationChanged(station: Station): void;
}

class PlayerService {
  private avPlayer: avPlayer.AVPlayer = null;
  private currentStation: Station = null;
  private state: PlayerState = PlayerState.IDLE;
  private callbacks: PlayerCallback[] = [];

  /**
   * Initialize the player
   */
  async initialize(): Promise<void> {
    try {
      this.avPlayer = await avPlayer.createAVPlayer();
      this.setupEventListeners();
      hilog.info(DOMAIN, TAG, 'AVPlayer initialized');
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to initialize AVPlayer: ' + JSON.stringify(e));
      this.notifyError('Failed to initialize player');
    }
  }

  /**
   * Setup event listeners for AVPlayer
   */
  private setupEventListeners(): void {
    if (!this.avPlayer) return;

    // State change events
    this.avPlayer.on('stateChange', (state) => {
      hilog.info(DOMAIN, TAG, 'Player state changed to: ' + state);
      
      switch (state) {
        case 'idle':
          this.state = PlayerState.IDLE;
          break;
        case 'loading':
          this.state = PlayerState.LOADING;
          break;
        case 'ready':
          this.state = PlayerState.PAUSED;
          break;
        case 'playing':
          this.state = PlayerState.PLAYING;
          break;
        case 'paused':
          this.state = PlayerState.PAUSED;
          break;
        case 'stopped':
          this.state = PlayerState.STOPPED;
          break;
        case 'error':
          this.state = PlayerState.ERROR;
          break;
        default:
          break;
      }
      
      this.notifyStateChanged();
    });

    // Error events
    this.avPlayer.on('error', (err) => {
      hilog.error(DOMAIN, TAG, 'Player error: ' + JSON.stringify(err));
      this.state = PlayerState.ERROR;
      this.notifyError(err.message || 'Playback error');
      this.notifyStateChanged();
    });

    // End of stream
    this.avPlayer.on('endOfStream', () => {
      hilog.info(DOMAIN, TAG, 'End of stream');
      this.state = PlayerState.STOPPED;
      this.notifyStateChanged();
    });
  }

  /**
   * Play a station
   */
  async play(station: Station): Promise<void> {
    if (!this.avPlayer) {
      await this.initialize();
    }

    if (!station || !station.getStreamUri()) {
      hilog.error(DOMAIN, TAG, 'Invalid station or stream URI');
      this.notifyError('Invalid station');
      return;
    }

    try {
      this.currentStation = station;
      this.state = PlayerState.LOADING;
      this.notifyStateChanged();
      this.notifyStationChanged();

      // Configure media source
      const mediaConfig = {
        bitsRate: station.bitrate || 128000,
        description: station.name
      };

      // Set URL source
      await this.avPlayer.setUrlSource(station.getStreamUri());
      
      // Prepare and play
      await this.avPlayer.prepare();
      await this.avPlayer.play();
      
      hilog.info(DOMAIN, TAG, 'Started playing: ' + station.name);
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to play: ' + JSON.stringify(e));
      this.state = PlayerState.ERROR;
      this.notifyError('Failed to play: ' + (e.message || 'Unknown error'));
      this.notifyStateChanged();
    }
  }

  /**
   * Stop playback
   */
  async stop(): Promise<void> {
    try {
      if (this.avPlayer) {
        await this.avPlayer.stop();
        await this.avPlayer.reset();
        this.state = PlayerState.STOPPED;
        this.notifyStateChanged();
        hilog.info(DOMAIN, TAG, 'Playback stopped');
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to stop: ' + JSON.stringify(e));
    }
  }

  /**
   * Pause playback
   */
  async pause(): Promise<void> {
    try {
      if (this.avPlayer && this.state === PlayerState.PLAYING) {
        await this.avPlayer.pause();
        this.state = PlayerState.PAUSED;
        this.notifyStateChanged();
        hilog.info(DOMAIN, TAG, 'Playback paused');
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to pause: ' + JSON.stringify(e));
    }
  }

  /**
   * Resume playback
   */
  async resume(): Promise<void> {
    try {
      if (this.avPlayer && this.state === PlayerState.PAUSED) {
        await this.avPlayer.play();
        this.state = PlayerState.PLAYING;
        this.notifyStateChanged();
        hilog.info(DOMAIN, TAG, 'Playback resumed');
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to resume: ' + JSON.stringify(e));
    }
  }

  /**
   * Toggle play/pause
   */
  async togglePlayPause(): Promise<void> {
    if (this.state === PlayerState.PLAYING) {
      await this.pause();
    } else if (this.state === PlayerState.PAUSED) {
      await this.resume();
    }
  }

  /**
   * Release player resources
   */
  async release(): Promise<void> {
    try {
      if (this.avPlayer) {
        await this.avPlayer.release();
        this.avPlayer = null;
        this.state = PlayerState.IDLE;
        this.currentStation = null;
        hilog.info(DOMAIN, TAG, 'Player released');
      }
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to release player: ' + JSON.stringify(e));
    }
  }

  /**
   * Get current state
   */
  getState(): PlayerState {
    return this.state;
  }

  /**
   * Get current station
   */
  getCurrentStation(): Station {
    return this.currentStation;
  }

  /**
   * Check if currently playing
   */
  isPlaying(): boolean {
    return this.state === PlayerState.PLAYING;
  }

  /**
   * Register callback
   */
  registerCallback(callback: PlayerCallback): void {
    const index = this.callbacks.indexOf(callback);
    if (index === -1) {
      this.callbacks.push(callback);
    }
  }

  /**
   * Unregister callback
   */
  unregisterCallback(callback: PlayerCallback): void {
    const index = this.callbacks.indexOf(callback);
    if (index !== -1) {
      this.callbacks.splice(index, 1);
    }
  }

  /**
   * Notify all callbacks of state change
   */
  private notifyStateChanged(): void {
    for (const callback of this.callbacks) {
      callback.onPlaybackStateChanged(this.state);
    }
  }

  /**
   * Notify all callbacks of error
   */
  private notifyError(error: string): void {
    for (const callback of this.callbacks) {
      callback.onError(error);
    }
  }

  /**
   * Notify all callbacks of station change
   */
  private notifyStationChanged(): void {
    if (this.currentStation) {
      for (const callback of this.callbacks) {
        callback.onStationChanged(this.currentStation);
      }
    }
  }
}

// Singleton instance
export const playerService = new PlayerService();

export default playerService;
