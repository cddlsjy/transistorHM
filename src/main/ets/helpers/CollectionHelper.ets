/**
 * CollectionHelper.ets
 * Handles collection operations
 * Converted from Android to HarmonyOS
 */

import { Collection } from '../models/Collection';
import { Station } from '../models/Station';
import FileHelper from './FileHelper';
import Context from '@ohos.app.ability.Context';

const COLLECTION_FILE = 'collection.json';

/**
 * Load collection from storage
 */
export function loadCollection(context: Context): Collection {
  try {
    const collectionPath = context.filesDir + '/' + COLLECTION_FILE;
    
    if (FileHelper.fileExists(collectionPath)) {
      const jsonContent = FileHelper.readTextFile(collectionPath);
      if (jsonContent) {
        const json = JSON.parse(jsonContent);
        return Collection.fromJSON(json);
      }
    }
  } catch (e) {
    console.error('Error loading collection: ' + JSON.stringify(e));
  }
  return new Collection();
}

/**
 * Save collection to storage
 */
export function saveCollection(context: Context, collection: Collection, async: boolean = true): void {
  try {
    const collectionPath = context.filesDir + '/' + COLLECTION_FILE;
    const jsonContent = JSON.stringify(collection.toJSON());
    FileHelper.writeTextFile(collectionPath, jsonContent);
  } catch (e) {
    console.error('Error saving collection: ' + JSON.stringify(e));
  }
}

/**
 * Add station to collection
 */
export function addStation(context: Context, station: Station): void {
  const collection = loadCollection(context);
  collection.addStation(station);
  saveCollection(context, collection);
}

/**
 * Remove station from collection
 */
export function removeStation(context: Context, station: Station): void {
  const collection = loadCollection(context);
  collection.removeStation(station.uuid);
  saveCollection(context, collection);
}

/**
 * Delete station and its images
 */
export function deleteStation(context: Context, station: Station): void {
  // Delete images
  if (station.image) {
    FileHelper.deleteFile(station.image);
  }
  if (station.smallImage) {
    FileHelper.deleteFile(station.smallImage);
  }
  // Remove from collection
  removeStation(context, station);
}

/**
 * Get station position in collection
 */
export function getStationPosition(collection: Collection, uuid: string): number {
  return collection.getStationPosition(uuid);
}

/**
 * Sort collection
 */
export function sortCollection(collection: Collection): Collection {
  return collection.sort();
}

/**
 * Delete station images
 */
export function deleteStationImages(context: Context, station: Station): void {
  if (station.image) {
    FileHelper.deleteFile(station.image);
  }
  if (station.smallImage) {
    FileHelper.deleteFile(station.smallImage);
  }
}

export default {
  loadCollection,
  saveCollection,
  addStation,
  removeStation,
  deleteStation,
  getStationPosition,
  sortCollection,
  deleteStationImages
};
