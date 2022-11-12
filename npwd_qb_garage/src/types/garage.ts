export interface GarageItem {
  stored: boolean;
	body: number;
    engine: number;
    fuel: number;
    garage: string;
    hash: string;
    plate: string;
    state: 'out' | 'garaged' | 'impounded' | 'seized' | 'unknown';
    vehicle: string;
    brand: string;
	type: 'car' | 'aircraft' | 'boat' | 'bike';
}