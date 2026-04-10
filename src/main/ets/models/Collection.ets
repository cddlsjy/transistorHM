/**
 * Collection.ets
 * Data model for a collection of radio stations
 * Converted from Android/Kotlin to ArkTS
 * Original: org.y20k.transistor.core.Collection
 */

import { Station } from './Station';

export class Collection {
  stations: Station[];
  
  constructor(stations: Station[] = []) {
    this.stations = stations;
  }
  
  /**
   * Get station count
   */
  size(): number {
    return this.stations.length;
  }
  
  /**
   * Check if collection is empty
   */
  isEmpty(): boolean {
    return this.stations.length === 0;
  }
  
  /**
   * Find station by UUID
   */
  findByUuid(uuid: string): Station | undefined {
    return this.stations.find(station => station.uuid === uuid);
  }
  
  /**
   * Get position of station by UUID
   */
  getStationPosition(uuid: string): number {
    return this.stations.findIndex(station => station.uuid === uuid);
  }
  
  /**
   * Add station to collection
   */
  addStation(station: Station): void {
    this.stations.push(station);
  }
  
  /**
   * Remove station by UUID
   */
  removeStation(uuid: string): void {
    const index = this.getStationPosition(uuid);
    if (index !== -1) {
      this.stations.splice(index, 1);
    }
  }
  
  /**
   * Sort stations (starred first, then by name)
   */
  sort(): Collection {
    const sortedStations = [...this.stations].sort((a, b) => {
      // Starred stations first
      if (a.starred && !b.starred) return -1;
      if (!a.starred && b.starred) return 1;
      // Then sort by name
      return a.name.localeCompare(b.name);
    });
    return new Collection(sortedStations);
  }
  
  /**
   * Create a deep copy
   */
  deepCopy(): Collection {
    return new Collection(this.stations.map(station => station.deepCopy()));
  }
  
  /**
   * Convert to JSON for storage
   */
  toJSON(): object {
    return {
      stations: this.stations.map(station => station.toJSON())
    };
  }
  
  /**
   * Create from JSON
   */
  static fromJSON(json: any): Collection {
    const stations = (json.stations || []).map((stationJson: any) => Station.fromJSON(stationJson));
    return new Collection(stations);
  }
}
