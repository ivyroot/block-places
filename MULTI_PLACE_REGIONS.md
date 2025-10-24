# Multi-Place Regions: Origin Convention

## Summary

Multi-place regions in BlockPlaces use a **northwest corner origin** 
convention. This is the authoritative specification defined in the 
Solidity smart contract and must be followed by all implementations.

## The Canonical Definition

The smart contract function `placeIdsInSquare()` in `BlockPlaces.sol` 
explicitly names its parameter `northWestPlaceId`:

```solidity
function placeIdsInSquare(
    uint256 northWestPlaceId, 
    uint256 size
) public pure returns (uint256[] memory)
```

### Expansion Logic

Starting from the northwest origin, the function expands:
- **Eastward** (positive longitude): `lng + j`
- **Southward** (negative latitude): `lat - i`

See lines 146-156 in `src/BlockPlaces.sol`:

```solidity
for (uint i = 0; i < size; i++) {
    for (uint j = 0; j < size; j++) {
        uint expandedLng = (lngOrigin * 100) + lngDecimalOrigin + j;
        uint currLng = expandedLng / 100;
        uint currLngDecimal = expandedLng % 100;
        uint expandedLat = (latOrigin * 100) + latDecimalOrigin - i;
        uint currLat = expandedLat / 100;
        uint currLatDecimal = expandedLat % 100;
        placeId = placeIdFromBlockPlace(
            currLng, 
            currLngDecimal, 
            currLat, 
            currLatDecimal
        );
        placeIds[i * size + j] = placeId;
    }
}
```

## Usage in Smart Contracts

The StickerChain contract (and any contract using BlockPlaces) calls:

```solidity
uint[] memory placeIds = BlockPlaces.placeIdsInSquare(
    _placeId, 
    size
);
```

The `_placeId` parameter here **must be** the northwest corner place.

## Rendering Multi-Place Regions

When rendering a multi-place region on a map:

1. **Origin Place Bounds**: Get bounds for the origin place ID
2. **Calculate SW Corner**: 
   - `lng = originPlace.west`
   - `lat = originPlace.north - (size × 0.01)`
3. **Calculate NE Corner**:
   - `lng = originPlace.west + (size × 0.01)` 
   - `lat = originPlace.north`

### Common Mistake

❌ **WRONG**: Treating the placeId as the **southwest** corner
```typescript
// This produces incorrect positioning!
const corner = {
    lng: originBounds.getWest(),
    lat: originBounds.getSouth() - extraLength  // Wrong!
};
```

✅ **CORRECT**: Treating the placeId as the **northwest** corner
```typescript
// Correct positioning matching the smart contract
const corner = {
    lng: originBounds.getWest(),
    lat: originBounds.getNorth() - (size * 0.01)  // Correct!
};
```

## Implementation Files

- **Solidity**: `src/BlockPlaces.sol` - `placeIdsInSquare()` function
- **TypeScript**: `typescript/src/BlockPlaces.ts` - 
  `sizedLngLatBoundsFromPlaceId()` method
- **Tests**: `test/SquareRegions.t.sol` - Multi-place region tests

## Why This Matters

Using the wrong corner (e.g., southwest instead of northwest) causes:
- **Off-by-one errors** in geographic positioning
- **Incorrect rendering** of multi-place regions on maps
- **Misalignment** between on-chain data and visual display
- **Data integrity issues** when regions don't match contract reality

## Verification

To verify correct implementation, render a size=2 slap and confirm:
1. The on-chain contract places it at the expected coordinates
2. The map display shows it at those same coordinates
3. All 4 places (2×2 grid) align with the northwest origin

Any discrepancy indicates incorrect origin handling in the render code.

