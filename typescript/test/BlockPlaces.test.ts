import { BlockPlaces, BlockPlace } from '../src/BlockPlaces';
import { LngLat } from 'maplibre-gl';

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
    const expectedPlaceId = 123;
    expect(BlockPlaces.enclosingPlaceIdForPoint(point)).toBe(expectedPlaceId);
  });

  // Add more test cases for different points, including edge cases
});
