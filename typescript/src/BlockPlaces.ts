import { LngLatBounds, LngLat } from 'maplibre-gl'
export type PlaceId = number;

export type BlockPlace = {
    lng: number;
    lngDecimal: number;
    lat: number;
    latDecimal: number;
};

// Map between (Longitude, Latitude) pairs and single PlaceId's
// PlaceIds store 2 digit precision for longitude and latitude, ie 0.01 degree precision
export class BlockPlaces {

    static isValidBlockPlace(location: BlockPlace): boolean {
        const { lng, lngDecimal, lat, latDecimal } = location;
        return (
            lng < 360 && lng >= 0
            && lngDecimal < 100 && lngDecimal >= 0
            && lat < 180 && lat >= 0
            && latDecimal < 100 && latDecimal >= 0
        );
    }

    static validateBlockPlace(location: BlockPlace): void {
        if (!this.isValidBlockPlace(location)) {
            throw new Error("Invalid longitude or latitude values for BlockPlace.");
        }
    }

    static enclosingPlaceIdForPoint(point: LngLat): PlaceId {
        const lng = Math.floor(point.lng) + 180;
        const lngDecimal = Math.floor((point.lng - lng + 180) * 100);
        const lat = Math.floor(point.lat) + 90;
        const latDecimal = Math.floor((point.lat - lat + 90) * 100);
        const location = { lng, lngDecimal, lat, latDecimal };
        this.validateBlockPlace(location);
        return this.placeIdFromBlockPlace(location);
    }

    static placeIdFromBlockPlace(location: BlockPlace): PlaceId {
        this.validateBlockPlace(location);
        const { lng, lngDecimal, lat, latDecimal } = location;
        const uint256_1 = BigInt(lng) << BigInt(26);
        const uint256_2 = BigInt(lngDecimal) << BigInt(18);
        const uint256_3 = BigInt(lat) << BigInt(10);
        const uint256_4 = BigInt(latDecimal) << BigInt(2);
        const patternCode = uint256_1 | uint256_2 | uint256_3 | uint256_4;
        return Number(patternCode | BigInt(3)); // Ensuring the last two bits are 1
    }

    static blockPlaceFromPlaceId(placeId: PlaceId): BlockPlace | null {
        const bigPlaceId = BigInt(placeId);
        if (bigPlaceId < 3 || bigPlaceId > BigInt(24118218127)) {
            return null;
        }
        const lngSrc = (bigPlaceId >> BigInt(26)) & BigInt(0xFFFF);
        const lngDecimalSrc = (bigPlaceId >> BigInt(18)) & BigInt(0xFF);
        const latSrc = (bigPlaceId >> BigInt(10)) & BigInt(0xFF);
        const latDecimalSrc = (bigPlaceId >> BigInt(2)) & BigInt(0xFF);
        const blockPlace = {
            lng: Number(lngSrc),
            lngDecimal: Number(lngDecimalSrc),
            lat: Number(latSrc),
            latDecimal: Number(latDecimalSrc)
        };
        if (!this.isValidBlockPlace(blockPlace)) {
            return null;
        }
        return blockPlace;
    }

    static lngLatBoundsFromPlaceId(placeId: PlaceId): LngLatBounds | null {
        const blockPlace = this.blockPlaceFromPlaceId(placeId);
        if (!blockPlace) {
            return null;
        }
        // translate from unsigned integers to signed integerers with
        // Longitute range -180 to 180 and Latitude range -90 to 90
        const lng = blockPlace.lng + blockPlace.lngDecimal / 100 - 180;
        const roundedLng = Math.round(lng * 100) / 100;
        const lat = blockPlace.lat + blockPlace.latDecimal / 100 - 90;
        const roundedLat = Math.round(lat * 100) / 100;
        const placeBounds = new LngLatBounds(new LngLat(roundedLng, roundedLat), new LngLat(roundedLng + 0.01, roundedLat + 0.01));
        return placeBounds;
    }

}
