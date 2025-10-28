import { LngLatBounds, LngLat } from 'maplibre-gl';
// Map between (Longitude, Latitude) pairs and single PlaceId's
// PlaceIds store 2 digit precision for longitude and latitude, ie 0.01 degree precision
export class BlockPlaces {
    static isValidBlockPlace(location) {
        const { lng, lngDecimal, lat, latDecimal } = location;
        return (lng < 360 && lng >= 0
            && lngDecimal < 100 && lngDecimal >= 0
            && lat < 180 && lat >= 0
            && latDecimal < 100 && latDecimal >= 0);
    }
    static validateBlockPlace(location) {
        if (!this.isValidBlockPlace(location)) {
            throw new Error("Invalid longitude or latitude values for BlockPlace.");
        }
    }
    static placeIdFromBlockPlace(location) {
        this.validateBlockPlace(location);
        const { lng, lngDecimal, lat, latDecimal } = location;
        const uint256_1 = BigInt(lng) << BigInt(26);
        const uint256_2 = BigInt(lat) << BigInt(18);
        const uint256_3 = BigInt(lngDecimal) << BigInt(10);
        const uint256_4 = BigInt(latDecimal) << BigInt(2);
        const patternCode = uint256_1 | uint256_2 | uint256_3 | uint256_4;
        return Number(patternCode | BigInt(3)); // Ensuring the last two bits are 1
    }
    static blockPlaceFromPlaceId(placeId) {
        const bigPlaceId = BigInt(placeId);
        if (bigPlaceId < 3 || bigPlaceId > BigInt(24139107727)) {
            return null;
        }
        const lngSrc = (bigPlaceId >> BigInt(26)) & BigInt(0xFFFF);
        const latSrc = (bigPlaceId >> BigInt(18)) & BigInt(0xFF);
        const lngDecimalSrc = (bigPlaceId >> BigInt(10)) & BigInt(0xFF);
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
    static enclosingPlaceIdForPoint(point) {
        const lng = Math.floor(point.lng) + 180;
        const lngDecimal = Math.floor((point.lng - lng + 180) * 100);
        const lat = Math.floor(point.lat) + 90;
        const latDecimal = Math.floor((point.lat - lat + 90) * 100);
        const location = { lng, lngDecimal, lat, latDecimal };
        this.validateBlockPlace(location);
        return this.placeIdFromBlockPlace(location);
    }
    static southwestCornerOfPlaceId(placeId) {
        const bounds = this.lngLatBoundsFromPlaceId(placeId);
        if (!bounds) {
            return null;
        }
        return bounds.getSouthWest();
    }
    static lngLatBoundsFromPlaceId(placeId) {
        const blockPlace = this.blockPlaceFromPlaceId(placeId);
        if (!blockPlace) {
            return null;
        }
        const lng = blockPlace.lng + blockPlace.lngDecimal / 100 - 180;
        const roundedLng = Math.round(lng * 100) / 100;
        const lat = blockPlace.lat + blockPlace.latDecimal / 100 - 90;
        const roundedLat = Math.round(lat * 100) / 100;
        const placeBounds = new LngLatBounds(new LngLat(roundedLng, roundedLat), new LngLat(roundedLng + 0.01, roundedLat + 0.01));
        return placeBounds;
    }
    /**
     * Calculate bounds for a multi-place region of given size.
     *
     * IMPORTANT: placeId is the NORTHWEST (top-left) corner of the region.
     * The region expands EAST and SOUTH from this origin point.
     *
     * This matches the Solidity contract placeIdsInSquare() function which
     * takes a northWestPlaceId parameter.
     *
     * @param placeId - The northwest corner place ID (origin)
     * @param size - Number of places in each direction (N×N region)
     * @returns LngLatBounds spanning the entire multi-place region
     */
    static sizedLngLatBoundsFromPlaceId(placeId, size) {
        const originPlaceBounds = this.lngLatBoundsFromPlaceId(placeId);
        if (!originPlaceBounds) {
            return null;
        }
        if (!size || size < 1) {
            throw new Error(`Invalid size ${size}`);
        }
        const extraLength = (size - 1) * 0.01;
        // Southwest corner: origin west, origin north - (size * 0.01)
        const sw = [
            originPlaceBounds.getWest(),
            originPlaceBounds.getSouth() - extraLength
        ];
        // Northeast corner: origin west + (size * 0.01), origin north
        const ne = [
            originPlaceBounds.getEast() + extraLength,
            originPlaceBounds.getNorth()
        ];
        const sizedBounds = new LngLatBounds(sw, ne);
        return sizedBounds;
    }
    static getPlaceIdsInBounds(bounds) {
        const points = [];
        const startLng = Math.ceil(bounds._sw.lng * 100) / 100;
        const startLat = Math.ceil(bounds._sw.lat * 100) / 100;
        const floatLngLength = bounds._ne.lng - bounds._sw.lng;
        const floatLatLength = bounds._ne.lat - bounds._sw.lat;
        const lngTotalSteps = Math.floor(floatLngLength * 100);
        const latTotalSteps = Math.floor(floatLatLength * 100);
        for (let lng = 0; lng < lngTotalSteps; lng += 1) {
            const lngPoint = Number((startLng + lng / 100).toFixed(2));
            for (let lat = 0; lat < latTotalSteps; lat += 1) {
                const latPoint = Number((startLat + lat / 100).toFixed(2));
                points.push(new LngLat(lngPoint, latPoint));
            }
        }
        const placeIds = points.map((point) => {
            const checkPoint = new LngLat(point.lng + 0.001, point.lat + 0.001);
            return this.enclosingPlaceIdForPoint(checkPoint);
        });
        return placeIds;
    }
    /**
     * Get all place IDs in a sized block place region.
     *
     * This is a convenience method that combines
     * sizedLngLatBoundsFromPlaceId and getPlaceIdsInBounds.
     *
     * @param placeId - The northwest corner place ID (origin)
     * @param size - Number of places in each direction (N×N region)
     * @returns Array of place IDs in the region
     */
    static getPlaceIdsForSizedBlockPlace(placeId, size) {
        const bounds = this.sizedLngLatBoundsFromPlaceId(placeId, size);
        if (!bounds) {
            return null;
        }
        return this.getPlaceIdsInBounds(bounds);
    }
}
//# sourceMappingURL=BlockPlaces.js.map