# Block Places

**Geographic translation utilities for use on the Blockchain**: ( Longitude, Latitude )  <-> ( Block Place Id )

**Author**: Ivyroot

**Description**:
- Block Places are a set of ids that can be used to identify locations anywhere on Earth.
- Each Block Place is a rectangular area whose sides are 1/100th of a degree long.
- They are stored as Longitude, Latitude pairs encoded in a single number, the Block Place ID.

**Details**:
- The Longitude and Latitude values for a Block Place are stored as two parts:
  - The first gives the non-decimal number, from 0-359 for Longitude and from 0-179 for Latitude.
  - The second gives the decimal in hundredths of a degree (e.g., 0.00, 0.01, 0.02 ... 0.99).

**Bitpacking**:
- The set of 4 values specifying a Block Place are bitpacked together into a single unique number:
  - `lng` values must be less than 360: stored as 16 bits.
  - `lat` values must be less than 180: stored as 8 bits.
  - `lngDecimal` and `latDecimal` values must be less than 100: stored as 8 bits each.

**Translation to Coordinates**:
- All values composing a BlockPlace are stored as unsigned (non-negative) values.
- When coordinates are passed in they have an offset added to them.
- When coordinates are passed out they have an offset subtracted from them.
