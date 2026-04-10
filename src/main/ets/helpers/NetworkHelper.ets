/**
 * NetworkHelper.ets
 * Handles network operations
 * Converted from Android to HarmonyOS
 * Original: org.y20k.transistor.helpers.NetworkHelper
 */

import http from '@ohos.net.http';
import connection from '@ohos.net.connection';

export interface NetworkResponse {
  code: number;
  contentType: string;
  data: string;
}

/**
 * Detect content type from URL
 */
export function detectContentType(url: string): { type: string; subtype: string } {
  return new Promise<{ type: string; subtype: string }>((resolve) => {
    try {
      const httpRequest = http.createHttp();
      httpRequest.request(url, {
        method: http.RequestMethod.HEAD,
        connectTimeout: 10000,
        readTimeout: 10000
      }, (err, data) => {
        if (err || data.responseCode >= 400) {
          resolve({ type: 'unknown', subtype: 'unknown' });
          return;
        }
        
        const contentType = data.header['Content-Type'] || '';
        const parts = contentType.split('/');
        resolve({
          type: parts[0] || 'unknown',
          subtype: parts[1] || 'unknown'
        });
      });
    } catch (e) {
      resolve({ type: 'unknown', subtype: 'unknown' });
    }
  }) as any;
}

/**
 * Synchronous content type detection
 */
export function detectContentTypeSync(url: string): string {
  try {
    // For streaming URLs, return common audio types
    if (url.includes('.mp3') || url.includes('audio/mpeg')) {
      return 'audio/mpeg';
    }
    if (url.includes('.aac') || url.includes('audio/aac')) {
      return 'audio/aac';
    }
    if (url.includes('.m3u') || url.includes('.m3u8')) {
      return 'application/x-mpegurl';
    }
    if (url.includes('.pls')) {
      return 'audio/x-scpls';
    }
    // Default to MP3 as most streams use it
    return 'audio/mpeg';
  } catch (e) {
    console.error('Error detecting content type: ' + JSON.stringify(e));
    return 'unknown';
  }
}

/**
 * Check network availability
 */
export function isNetworkAvailable(): boolean {
  try {
    const netHandle = connection.getDefaultNetSync();
    return netHandle !== null;
  } catch (e) {
    console.error('Error checking network: ' + JSON.stringify(e));
    return false;
  }
}

/**
 * Fetch data from URL
 */
export function fetch(url: string): Promise<string> {
  return new Promise<string>((resolve, reject) => {
    try {
      const httpRequest = http.createHttp();
      httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 30000,
        readTimeout: 30000
      }, (err, data) => {
        if (err) {
          reject(err);
          return;
        }
        
        if (data.responseCode >= 200 && data.responseCode < 300) {
          resolve(data.result as string);
        } else {
          reject(new Error('HTTP Error: ' + data.responseCode));
        }
      });
    } catch (e) {
      reject(e);
    }
  });
}

/**
 * Download image from URL
 */
export async function downloadImage(url: string, localPath: string): Promise<void> {
  try {
    const response = await fetch(url);
    // Save to local path
    const fs = require('@ohos.file.fs');
    const file = fs.openSync(localPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    fs.writeSync(file.fd, response);
    fs.closeSync(file);
  } catch (e) {
    console.error('Error downloading image: ' + JSON.stringify(e));
    throw e;
  }
}

/**
 * Parse M3U playlist
 */
export function parseM3UPlaylist(content: string): string[] {
  const urls: string[] = [];
  const lines = content.split('\n');
  
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith('#') && (trimmed.startsWith('http://') || trimmed.startsWith('https://'))) {
      urls.push(trimmed);
    }
  }
  
  return urls;
}

/**
 * Parse PLS playlist
 */
export function parsePLSPlaylist(content: string): string[] {
  const urls: string[] = [];
  const lines = content.split('\n');
  
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('File')) {
      const match = trimmed.match(/File\d+=(.+)/);
      if (match) {
        urls.push(match[1].trim());
      }
    }
  }
  
  return urls;
}

export default {
  detectContentType,
  detectContentTypeSync,
  isNetworkAvailable,
  fetch,
  downloadImage,
  parseM3UPlaylist,
  parsePLSPlaylist
};
