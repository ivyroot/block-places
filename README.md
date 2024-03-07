# Block Places

**Geographic translation utilities for use on the Blockchain**: ( Longitude, Latitude )  <-> ( Block Place Id )

**Author**: Ivyroot https://warpcast.com/ivyroot

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
- They are mapped to geographic coordinates using offsets that remove negative values.
- When geographic coordinates are passed in they have an offset added to them.
- When geographic coordinates are passed out they have an offset subtracted from them.
- The offset is 180 for Longitude and 90 for Latitude.