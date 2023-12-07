// SPDX-License-Identifier: MIT
//
// Block Places
//
//  Geographic translation utilities:   (lng/lat) <-> (block place id)
//
//   Author: ivyroot
//
// Block Places are a set of ids that can be used to identify locations anywhere on Earth.
// Each Block Place is a rectangular area whose sides are 1/100th of a degree long.
// They are stored as Longitude, Latitude pairs encoded in a single number, the Block Place ID.
//
// The Longitude and Latitude values for a Block Place are stored as two parts.
// The first gives the whole number, from 0-359 for Longitude and from 0-179 for Latitude.
// The second gives the decimal in hundredths of a degree. Ex: 0.00, 0.01, 0.02, 0.03, etc.
// Decimals are numbers from 0-99.
//
// The set of 4 values specifying a Block Place are bitpacked together into a single unique number.
// lng values must be less than 360: stored as 16 bits
// lat values must be less than 180: stored as 8 bits
// lngDecimal and latDecimal values must be less than 100: stored as 8 bits
//
//
pragma solidity ^0.8.19;

library BlockPlaces {

    error LngMustBeUnder360();
    error LngDecimalMustBeUnder100();
    error LatMustBeUnder180();
    error LatDecimalMustBeUnder100();

    function isValidLngLat(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure returns (uint256) {
        if (lng >= 360) {
            return 1;
        }
        if (lngDecimal >= 100) {
            return 2;
        }
        if (lat >= 180) {
            return 3;
        }
        if (latDecimal >= 100) {
            return 4;
        }
        return 0;
    }

    function validateLngLat(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure {
        uint isValid = isValidLngLat(lng, lngDecimal, lat, latDecimal);
        if (isValid == 1) {
            revert LngMustBeUnder360();
        }
        if (isValid == 2) {
            revert LngDecimalMustBeUnder100();
        }
        if (isValid == 3) {
            revert LatMustBeUnder180();
        }
        if (isValid == 4) {
            revert LatDecimalMustBeUnder100();
        }
    }

    // Bit packs 4 geo location uints together with the last two bits set to 1
    function placeIdFromLngLat(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure returns (uint256) {
        validateLngLat(lng, lngDecimal, lat, latDecimal);

        uint256 uint256_1 = lng << 26; // values < 360. use 16 bits
        uint256 uint256_2 = lngDecimal << 18; // values < 100. use 8 bits
        uint256 uint256_3 = lat << 10; // values < 180. use 8 bits
        uint256 uint256_4 = latDecimal << 2; // values < 100. use 8 bits

        // Return the bit packed uint256 with the last two bits set to 1 to ensure it's never 0.
        uint256 patternCode = uint256_1 | uint256_2 | uint256_3 | uint256_4;
        return patternCode | 3;  // Ensuring the last two bits are 1
    }

    // Unpack a bit packed block id into 4 geo location uints
    function lngLatFromPlaceId(uint256 _placeId) public pure returns (bool isValid, uint lng, uint lngDecimal, uint lat, uint latDecimal) {
        // Ensure the last two bits are set to 1
        if((_placeId & 3) != 3) {
            return(false, 0, 0, 0, 0);
        }

        // Ensure there is not extra bits in front
        if (_placeId > 24118218127) {
            return(false, 0, 0, 0, 0);
        }

        // Shift the values out of the correct positions
        uint16 lngSrc = uint16(_placeId >> 26);
        uint8 lngDecimalSrc = uint8(_placeId >> 18);
        uint8 latSrc = uint8(_placeId >> 10);
        uint8 latDecimalSrc = uint8(_placeId >> 2);
        if (isValidLngLat(lngSrc, lngDecimalSrc, latSrc, latDecimalSrc) > 0) {
            return(false, 0, 0, 0, 0);
        }

        isValid = true;
        lng = uint(lngSrc);
        lngDecimal = uint(lngDecimalSrc);
        lat = uint(latSrc);
        latDecimal = uint(latDecimalSrc);
    }


}
