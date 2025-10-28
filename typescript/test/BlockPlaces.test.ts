import { BlockPlaces, BlockPlace } from '../src/BlockPlaces';
import { LngLat, LngLatBounds } from 'maplibre-gl';

// Describe block for BlockPlaces.isValidBlockPlace
describe('BlockPlaces.isValidBlockPlace', () => {
  it('should return true for valid BlockPlace objects', () => {
    const validPlace = { lng: 100, lngDecimal: 50, lat: 50, latDecimal: 50 };
    expect(BlockPlaces.isValidBlockPlace(validPlace)).toBe(true);
  });

  it('should return false for invalid BlockPlace objects', () => {
    const invalidPlace = { lng: 400, lngDecimal: 50, lat: 50, latDecimal: 50 };
    expect(BlockPlaces.isValidBlockPlace(invalidPlace)).toBe(false);
  });

  // Add more test cases for other edge cases and invalid inputs
});

// Describe block for BlockPlaces.validateBlockPlace
describe('BlockPlaces.validateBlockPlace', () => {
  it('should not throw an error for a valid BlockPlace object', () => {
    const validPlace = { lng: 100, lngDecimal: 50, lat: 50, latDecimal: 50 };
    expect(() => BlockPlaces.validateBlockPlace(validPlace)).not.toThrow();
  });

  it('should throw an error for an invalid BlockPlace object', () => {
    const invalidPlace = { lng: 400, lngDecimal: 50, lat: 50, latDecimal: 50 };
    expect(() => BlockPlaces.validateBlockPlace(invalidPlace)).toThrow("Invalid longitude or latitude values for BlockPlace.");
  });

  // Add more test cases for other invalid inputs
});

// Describe block for BlockPlaces.enclosingPlaceIdForPoint
describe('BlockPlaces.enclosingPlaceIdForPoint', () => {
  it('should return the correct PlaceId for a given point', () => {
    const point = new LngLat(100, 50);
    const expectedPlaceId = 18827182083;
    expect(BlockPlaces.enclosingPlaceIdForPoint(point)).toBe(expectedPlaceId);
  });

  // Add more test cases for different points, including edge cases
});

describe('getPlaceIdsInBounds', () => {
  it('should return the correct PlaceIds for a given bounding box', () => {
    const bounds = new LngLatBounds([[99.995, 49.995], [100.015, 50.015]]);
    // For a 0.02 x 0.02 degree bounds, we expect 2x2 = 4 places
    const expectedPlaceIds = [18827182083,
      18827182087,
    ];
    expect(BlockPlaces.getPlaceIdsInBounds(bounds)).toEqual(expectedPlaceIds);
  });
});

describe('getPlaceIdsForSizedBlockPlace', () => {
  it('should return exactly 4 places for a size 2 slap', () => {
    // This tests the fix for the bug where size 2 slaps
    // were incorrectly getting 6 places (3x2 grid) 
    // instead of 4 places (2x2 grid)
    const placeId = 6674012507; // Origin place from the log
    const size = 2;
    const placeIds = BlockPlaces.getPlaceIdsForSizedBlockPlace(
      placeId,
      size
    );
    expect(placeIds).not.toBeNull();
    expect(placeIds?.length).toBe(4); // size^2 = 2^2 = 4
  });

  it('should return exactly 9 places for a size 3 slap', () => {
    const placeId = 6674012507;
    const size = 3;
    const placeIds = BlockPlaces.getPlaceIdsForSizedBlockPlace(
      placeId,
      size
    );
    expect(placeIds).not.toBeNull();
    expect(placeIds?.length).toBe(9); // size^2 = 3^2 = 9
  });

  it('should return exactly 1 place for a size 1 slap', () => {
    const placeId = 6674012507;
    const size = 1;
    const placeIds = BlockPlaces.getPlaceIdsForSizedBlockPlace(
      placeId,
      size
    );
    expect(placeIds).not.toBeNull();
    expect(placeIds?.length).toBe(1); // size^2 = 1^2 = 1
  });
});
