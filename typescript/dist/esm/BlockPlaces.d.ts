import { LngLatBounds, LngLat } from 'maplibre-gl';
export type PlaceId = number;
export type BlockPlace = {
    lng: number;
    lngDecimal: number;
    lat: number;
    latDecimal: number;
};
export declare class BlockPlaces {
    static isValidBlockPlace(location: BlockPlace): boolean;
    static validateBlockPlace(location: BlockPlace): void;
    static placeIdFromBlockPlace(location: BlockPlace): PlaceId;
    static blockPlaceFromPlaceId(placeId: PlaceId): BlockPlace | null;
    static enclosingPlaceIdForPoint(point: LngLat): PlaceId;
    static southwestCornerOfPlaceId(placeId: PlaceId): LngLat | null;
    static lngLatBoundsFromPlaceId(placeId: PlaceId): LngLatBounds | null;
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
    static sizedLngLatBoundsFromPlaceId(placeId: PlaceId, size: number): LngLatBounds | null;
    static getPlaceIdsInBounds(bounds: LngLatBounds): PlaceId[];
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
    static getPlaceIdsForSizedBlockPlace(placeId: PlaceId, size: number): PlaceId[] | null;
}
//# sourceMappingURL=BlockPlaces.d.ts.map