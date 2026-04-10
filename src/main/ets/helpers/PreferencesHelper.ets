/**
 * PreferencesHelper.ets
 * Handles app preferences storage
 * Converted from Android to HarmonyOS
 * Original: org.y20k.transistor.helpers.PreferencesHelper
 */

import dataPreferences from '@ohos.data.preferences';
import dataAbility from '@ohos.data.ability';
import Context from '@ohos.app.ability.Context';

const PREFERENCES_NAME = 'transistor_preferences';
const CONTEXT: Context = null;

// Preference keys
export const PREF_THEME_SELECTION = 'theme_selection';
export const PREF_EDIT_STATIONS = 'edit_stations_enabled';
export const PREF_EDIT_STREAMS_URIS = 'edit_streams_uris_enabled';
export const PREF_TAP_ANYWHERE_PLAYBACK = 'tap_anywhere_playback';
export const PREF_STATION_LIST_EXPANDED = 'station_list_expanded_uuid';
export const PREF_COLLECTION_SIZE = 'collection_size';

// Theme values
export const THEME_LIGHT = 0;
export const THEME_DARK = 1;
export const THEME_SYSTEM = 2;

// Default values
const DEFAULT_STATION_LIST_EXPANDED = '';
const DEFAULT_COLLECTION_SIZE = -1;
const DEFAULT_EDIT_STATIONS = false;
const DEFAULT_EDIT_STREAMS_URIS = false;
const DEFAULT_TAP_ANYWHERE_PLAYBACK = false;
const DEFAULT_THEME = THEME_SYSTEM;

let preferencesInstance: dataPreferences.Preferences = null;

/**
 * Initialize preferences
 */
export function init(context: Context): void {
  try {
    dataPreferences.getPreferences(context, PREFERENCES_NAME, (err, prefs) => {
      if (err) {
        console.error('Failed to get preferences: ' + JSON.stringify(err));
        return;
      }
      preferencesInstance = prefs;
    });
  } catch (e) {
    console.error('Error initializing preferences: ' + JSON.stringify(e));
  }
}

/**
 * Get preferences instance
 */
function getPreferences(): dataPreferences.Preferences {
  return preferencesInstance;
}

/**
 * Load theme selection
 */
export function loadThemeSelection(): number {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_THEME_SELECTION, DEFAULT_THEME);
    }
  } catch (e) {
    console.error('Error loading theme: ' + JSON.stringify(e));
  }
  return DEFAULT_THEME;
}

/**
 * Save theme selection
 */
export function saveThemeSelection(theme: number): void {
  try {
    if (getPreferences()) {
      getPreferences().putSync(PREF_THEME_SELECTION, theme);
      getPreferences().flush();
    }
  } catch (e) {
    console.error('Error saving theme: ' + JSON.stringify(e));
  }
}

/**
 * Load edit stations enabled
 */
export function loadEditStationsEnabled(): boolean {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_EDIT_STATIONS, DEFAULT_EDIT_STATIONS);
    }
  } catch (e) {
    console.error('Error loading edit stations: ' + JSON.stringify(e));
  }
  return DEFAULT_EDIT_STATIONS;
}

/**
 * Save edit stations enabled
 */
export function saveEditStationsEnabled(enabled: boolean): void {
  try {
    if (getPreferences()) {
      getPreferences().putSync(PREF_EDIT_STATIONS, enabled);
      getPreferences().flush();
    }
  } catch (e) {
    console.error('Error saving edit stations: ' + JSON.stringify(e));
  }
}

/**
 * Load edit stream URIs enabled
 */
export function loadEditStreamUrisEnabled(): boolean {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_EDIT_STREAMS_URIS, DEFAULT_EDIT_STREAMS_URIS);
    }
  } catch (e) {
    console.error('Error loading edit streams: ' + JSON.stringify(e));
  }
  return DEFAULT_EDIT_STREAMS_URIS;
}

/**
 * Load tap anywhere playback setting
 */
export function loadTapAnyWherePlayback(): boolean {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_TAP_ANYWHERE_PLAYBACK, DEFAULT_TAP_ANYWHERE_PLAYBACK);
    }
  } catch (e) {
    console.error('Error loading tap anywhere: ' + JSON.stringify(e));
  }
  return DEFAULT_TAP_ANYWHERE_PLAYBACK;
}

/**
 * Load station list expanded state
 */
export function loadStationListStreamUuid(): string {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_STATION_LIST_EXPANDED, DEFAULT_STATION_LIST_EXPANDED);
    }
  } catch (e) {
    console.error('Error loading station list state: ' + JSON.stringify(e));
  }
  return DEFAULT_STATION_LIST_EXPANDED;
}

/**
 * Save station list expanded state
 */
export function saveStationListStreamUuid(uuid: string): void {
  try {
    if (getPreferences()) {
      getPreferences().putSync(PREF_STATION_LIST_EXPANDED, uuid);
      getPreferences().flush();
    }
  } catch (e) {
    console.error('Error saving station list state: ' + JSON.stringify(e));
  }
}

/**
 * Load collection size
 */
export function loadCollectionSize(): number {
  try {
    if (getPreferences()) {
      return getPreferences().getSync(PREF_COLLECTION_SIZE, DEFAULT_COLLECTION_SIZE);
    }
  } catch (e) {
    console.error('Error loading collection size: ' + JSON.stringify(e));
  }
  return DEFAULT_COLLECTION_SIZE;
}

/**
 * Save collection size
 */
export function saveCollectionSize(size: number): void {
  try {
    if (getPreferences()) {
      getPreferences().putSync(PREF_COLLECTION_SIZE, size);
      getPreferences().flush();
    }
  } catch (e) {
    console.error('Error saving collection size: ' + JSON.stringify(e));
  }
}

/**
 * Check if housekeeping is necessary
 */
export function isHouseKeepingNecessary(): boolean {
  const size = loadCollectionSize();
  return size === DEFAULT_COLLECTION_SIZE;
}

/**
 * Save housekeeping necessary state
 */
export function saveHouseKeepingNecessaryState(): void {
  // Housekeeping done, nothing to do in HarmonyOS
}

export default {
  init,
  loadThemeSelection,
  saveThemeSelection,
  loadEditStationsEnabled,
  saveEditStationsEnabled,
  loadEditStreamUrisEnabled,
  loadTapAnyWherePlayback,
  loadStationListStreamUuid,
  saveStationListStreamUuid,
  loadCollectionSize,
  saveCollectionSize,
  isHouseKeepingNecessary,
  saveHouseKeepingNecessaryState
};
