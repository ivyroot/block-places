# Block Places

**Geographic translation utilities for use on the Blockchain**: ( Longitude, Latitude )  <-> ( Block Place Id )

**Author**: ivyroot: https://farcaster.xyz/ivyroot -  https://x.com/ivyroot_zk

**Description**:
- Block Places are a set of ids that can be used to identify locations anywhere on Earth.
- Each Block Place is a rectangular area with sides that are 1/100th of a degree long.
- They are stored as Longitude, Latitude pairs encoded in a single number, the Block Place ID.

**Components**:
- The Longitude and Latitude values for a Block Place are each stored as two parts:
  - The first gives the whole number, from 0-359 for Longitude and from 0-179 for Latitude.
  - The second gives the decimal in hundredths of a degree. So 0.00, 0.01, 0.02 ... 0.99 map to 0 through 99.

**Bitpacking**:
- The set of 4 values specifying a Block Place are bitpacked together into a single unique number:
  - Longitude whole degree values must be less than 360. They are stored as 16 bits.
  - Latitude whole degree values must be less than 180. They are stored as 8 bits.
  - Decimal values must be less than 100. They are stored as 8 bits each.
  - The byte ordering format is [Longitude][Latitude][Longitude Decimal][Latitude Decimal]

**Translation to Geographic Coordinates**:
- All values composing a BlockPlace are stored as non-negative integers.
- They are mapped to geographic coordinates using offsets that remove 
  negative values.
- When geographic coordinates are passed in they have an offset added 
  to them.
- When geographic coordinates are passed out they have an offset 
  subtracted from them.
- The offset is 180 for Longitude and 90 for Latitude.

## Multi-Place Regions (Square Regions)

**Overview**:
Block Places can represent regions larger than a single 0.01° × 0.01° 
square. Multi-place regions are defined by an **origin place** and a 
**size** parameter, where size indicates how many places the region 
spans in each direction.

**Origin Convention - Northwest Corner**:
The origin place for a multi-place region is always the **northwest 
(top-left) corner**. This convention is defined in the Solidity smart 
contract function `placeIdsInSquare(uint256 northWestPlaceId, uint256 
size)` in `BlockPlaces.sol`.

**Expansion Direction**:
From the northwest origin, the region expands:
- **EAST** (positive longitude direction): `lng + j`
- **SOUTH** (negative latitude direction): `lat - i`

For a region of `size = N`:
- **Width**: N places = N × 0.01° longitude
- **Height**: N places = N × 0.01° latitude
- **Total places**: N × N places

**Example - Size 2 Region**:
Given a northwest origin place at (lng: 100.50, lat: 40.75):
```
NW (origin)  |  NE
100.50, 40.75 | 100.51, 40.75
--------------+--------------
100.50, 40.74 | 100.51, 40.74
SW            |  SE
```

**Calculating Bounds**:
To calculate the geographic bounds of a multi-place region:

1. Get the origin place bounds (northwest corner)
2. Southwest corner latitude = `originNorth - (size × 0.01)`
3. Northeast corner longitude = `originEast + (size × 0.01)` 
   (equivalent to `originWest + (size × 0.01)`)
4. Final bounds: `[originWest, swLat] to [neLng, originNorth]`

**Implementation Reference**:
- **Solidity**: `placeIdsInSquare()` in `src/BlockPlaces.sol` 
  (lines 130-159)
- **TypeScript**: `sizedLngLatBoundsFromPlaceId()` in 
  `typescript/src/BlockPlaces.ts` (lines 94-108)

**Important Note for Rendering**:
When rendering multi-place regions on a map, always treat the provided 
placeId as the **northwest corner**. The region extends east and south 
from this origin. Using any other corner (e.g., southwest) will result 
in incorrect geographic positioning.