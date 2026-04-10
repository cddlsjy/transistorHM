/**
 * Station.ets
 * Data model for a radio station
 * Converted from Android/Kotlin to ArkTS
 * Original: org.y20k.transistor.core.Station
 */

import { v4 as uuidv4 } from './utils/uuid';

// MIME type constants
export const MIME_TYPE_UNSUPPORTED = 'unsupported';
export const MIME_TYPES_MPEG = ['audio/mpeg', 'audio/mp3', 'audio/mpeg3'];
export const MIME_TYPES_AAC = ['audio/aac', 'audio/aacp', 'audio/3gpp', 'audio/3gpp2', 'audio/mp4'];
export const MIME_TYPES_OGG = ['audio/ogg', 'audio/vorbis', 'audio/opus'];
export const MIME_TYPES_HLS = ['application/x-mpegurl', 'application/vnd.apple.mpegurl'];

export class Station {
  uuid: string;
  starred: boolean;
  name: string;
  nameManuallySet: boolean;
  streamUris: string[];
  stream: number;
  streamContent: string;
  homepage: string;
  image: string;
  smallImage: string;
  imageColor: number;
  imageManuallySet: boolean;
  remoteImageLocation: string;
  remoteStationLocation: string;
  modificationDate: Date;
  isPlaying: boolean;
  radioBrowserStationUuid: string;
  codec: string;
  bitrate: number;
  radioBrowserChangeUuid: string;

  constructor(
    uuid: string = uuidv4(),
    starred: boolean = false,
    name: string = '',
    nameManuallySet: boolean = false,
    streamUris: string[] = [],
    stream: number = 0,
    streamContent: string = MIME_TYPE_UNSUPPORTED,
    homepage: string = '',
    image: string = '',
    smallImage: string = '',
    imageColor: number = -1,
    imageManuallySet: boolean = false,
    remoteImageLocation: string = '',
    remoteStationLocation: string = '',
    modificationDate: Date = new Date(),
    isPlaying: boolean = false,
    radioBrowserStationUuid: string = '',
    codec: string = '',
    bitrate: number = 0,
    radioBrowserChangeUuid: string = ''
  ) {
    this.uuid = uuid;
    this.starred = starred;
    this.name = name;
    this.nameManuallySet = nameManuallySet;
    this.streamUris = streamUris;
    this.stream = stream;
    this.streamContent = streamContent;
    this.homepage = homepage;
    this.image = image;
    this.smallImage = smallImage;
    this.imageColor = imageColor;
    this.imageManuallySet = imageManuallySet;
    this.remoteImageLocation = remoteImageLocation;
    this.remoteStationLocation = remoteStationLocation;
    this.modificationDate = modificationDate;
    this.isPlaying = isPlaying;
    this.radioBrowserStationUuid = radioBrowserStationUuid;
    this.codec = codec;
    this.bitrate = bitrate;
    this.radioBrowserChangeUuid = radioBrowserChangeUuid;
  }

  /**
   * Get the currently selected stream URI
   */
  getStreamUri(): string {
    if (this.streamUris.length > 0 && this.stream < this.streamUris.length) {
      return this.streamUris[this.stream];
    }
    return '';
  }

  /**
   * Check if station has valid minimum data
   */
  isValid(): boolean {
    return (
      this.uuid.length > 0 &&
      this.name.length > 0 &&
      this.streamUris.length > 0 &&
      this.getStreamUri().length > 0 &&
      this.modificationDate !== null &&
      this.streamContent !== MIME_TYPE_UNSUPPORTED
    );
  }

  /**
   * Get media type for AVPlayer
   */
  getMediaType(): string {
    const content = this.streamContent.toLowerCase();
    
    if (MIME_TYPES_MPEG.some(type => content.includes(type.replace('audio/', '')))) {
      return 'audio/mp4'; // MP3 fallback
    } else if (MIME_TYPES_AAC.some(type => content.includes(type.replace('audio/', '')))) {
      return 'audio/aac';
    } else if (MIME_TYPES_HLS.some(type => content.includes(type))) {
      return 'application/x-mpegurl';
    } else if (MIME_TYPES_OGG.some(type => content.includes(type.replace('audio/', '')))) {
      return 'audio/ogg';
    }
    return 'audio/mp4'; // Default fallback
  }

  /**
   * Create a deep copy of this station
   */
  deepCopy(): Station {
    return new Station(
      this.uuid,
      this.starred,
      this.name,
      this.nameManuallySet,
      [...this.streamUris],
      this.stream,
      this.streamContent,
      this.homepage,
      this.image,
      this.smallImage,
      this.imageColor,
      this.imageManuallySet,
      this.remoteImageLocation,
      this.remoteStationLocation,
      this.modificationDate,
      this.isPlaying,
      this.radioBrowserStationUuid,
      this.codec,
      this.bitrate,
      this.radioBrowserChangeUuid
    );
  }

  /**
   * Convert to JSON for storage
   */
  toJSON(): object {
    return {
      uuid: this.uuid,
      starred: this.starred,
      name: this.name,
      nameManuallySet: this.nameManuallySet,
      streamUris: this.streamUris,
      stream: this.stream,
      streamContent: this.streamContent,
      homepage: this.homepage,
      image: this.image,
      smallImage: this.smallImage,
      imageColor: this.imageColor,
      imageManuallySet: this.imageManuallySet,
      remoteImageLocation: this.remoteImageLocation,
      remoteStationLocation: this.remoteStationLocation,
      modificationDate: this.modificationDate.toISOString(),
      isPlaying: this.isPlaying,
      radioBrowserStationUuid: this.radioBrowserStationUuid,
      codec: this.codec,
      bitrate: this.bitrate,
      radioBrowserChangeUuid: this.radioBrowserChangeUuid
    };
  }

  /**
   * Create from JSON
   */
  static fromJSON(json: any): Station {
    return new Station(
      json.uuid,
      json.starred,
      json.name,
      json.nameManuallySet,
      json.streamUris,
      json.stream,
      json.streamContent,
      json.homepage,
      json.image,
      json.smallImage,
      json.imageColor,
      json.imageManuallySet,
      json.remoteImageLocation,
      json.remoteStationLocation,
      new Date(json.modificationDate),
      json.isPlaying,
      json.radioBrowserStationUuid,
      json.codec,
      json.bitrate,
      json.radioBrowserChangeUuid
    );
  }
}
