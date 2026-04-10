/**
 * FileHelper.ets
 * Handles file operations
 * Converted from Android to HarmonyOS
 * Original: org.y20k.transistor.helpers.FileHelper
 */

import fs from '@ohos.file.fs';
import Context from '@ohos.app.ability.Context';

const STATIONS_FOLDER = 'stations';
const IMAGES_FOLDER = 'images';

/**
 * Create .nomedia file to prevent media scanning
 */
export function createNomediaFile(context: Context): void {
  try {
    const filesDir = context.filesDir;
    const nomediaPath = filesDir + '/.nomedia';
    
    if (!fs.accessSync(nomediaPath)) {
      const file = fs.openSync(nomediaPath, fs.OpenMode.CREATE);
      fs.closeSync(file);
    }
  } catch (e) {
    console.error('Error creating nomedia file: ' + JSON.stringify(e));
  }
}

/**
 * Get stations directory path
 */
export function getStationsDirectory(context: Context): string {
  return context.filesDir + '/' + STATIONS_FOLDER;
}

/**
 * Get images directory path
 */
export function getImagesDirectory(context: Context): string {
  return context.filesDir + '/' + IMAGES_FOLDER;
}

/**
 * Ensure directory exists
 */
export function ensureDirectoryExists(path: string): void {
  try {
    if (!fs.accessSync(path)) {
      fs.mkdirSync(path, true);
    }
  } catch (e) {
    console.error('Error creating directory: ' + JSON.stringify(e));
  }
}

/**
 * Get file size
 */
export function getFileSize(path: string): number {
  try {
    if (fs.accessSync(path)) {
      const stat = fs.statSync(path);
      return stat.size;
    }
  } catch (e) {
    console.error('Error getting file size: ' + JSON.stringify(e));
  }
  return 0;
}

/**
 * Check if file exists
 */
export function fileExists(path: string): boolean {
  try {
    return fs.accessSync(path);
  } catch (e) {
    return false;
  }
}

/**
 * Delete file
 */
export function deleteFile(path: string): void {
  try {
    if (fs.accessSync(path)) {
      fs.unlinkSync(path);
    }
  } catch (e) {
    console.error('Error deleting file: ' + JSON.stringify(e));
  }
}

/**
 * Read text file
 */
export function readTextFile(path: string): string {
  try {
    if (fs.accessSync(path)) {
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      const buffer = fs.readSync(file.fd);
      fs.closeSync(file);
      return buffer.toString();
    }
  } catch (e) {
    console.error('Error reading file: ' + JSON.stringify(e));
  }
  return '';
}

/**
 * Write text file
 */
export function writeTextFile(path: string, content: string): void {
  try {
    const file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    fs.writeSync(file.fd, content);
    fs.closeSync(file);
  } catch (e) {
    console.error('Error writing file: ' + JSON.stringify(e));
  }
}

/**
 * Get file name from path
 */
export function getFileName(path: string): string {
  const parts = path.split('/');
  return parts[parts.length - 1];
}

/**
 * Generate unique file name
 */
export function generateUniqueFileName(extension: string): string {
  const timestamp = Date.now();
  return `station_${timestamp}.${extension}`;
}

export default {
  createNomediaFile,
  getStationsDirectory,
  getImagesDirectory,
  ensureDirectoryExists,
  getFileSize,
  fileExists,
  deleteFile,
  readTextFile,
  writeTextFile,
  getFileName,
  generateUniqueFileName
};
