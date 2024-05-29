// SPDX-License-Identifier: MIT
//
// BlockPlaces
//
//  Geographic translation utilities:   (lng/lat) <-> (BlockPlace id)
//
//   Author: https://warpcast.com/ivyroot
//
// BlockPlaces are a set of ids that can be used to identify locations anywhere on Earth.
// Each BlockPlace is a rectangular area whose sides are 1/100th of a degree long.
// They are stored as Longitude, Latitude pairs encoded in a single number, the BlockPlace ID.
//
// Each Longitude and Latitude value in a BlockPlace is stored as two parts: the degree number and the first 2 digits of its decimal.
// The first gives the whole number, from 0-359 for Longitude and from 0-179 for Latitude.
// The second gives the decimal in hundredths of a degree. Ex: 0.00, 0.01, 0.02, 0.03, etc.
// Longitude and Latitude are translated from the typical range of [-180 to 180] and [-90 to 90] to be only positive numbers.
// Decimals are numbers from 0-99.
//
// The set of 4 values specifying a BlockPlace are bitpacked together into a single unique number.
// lng values are stored as 16 bits
// lat values are stored as 8 bits
// lngDecimal and latDecimal values are stored as 8 bits
//
//
pragma solidity ^0.8.19;

import "forge-std/console.sol";


library BlockPlaces {

    error ValMustBeGtZero(int val);
    error LngMustBeUnder360();
    error LngDecimalMustBeUnder100();
    error LatMustBeUnder180();
    error LatDecimalMustBeUnder100();
    error InvalidPlaceId();
    error InvalidSquareRegion();

    function isValidBlockPlace(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure returns (uint256) {
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

    function validateBlockPlace(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure {
        uint isValid = isValidBlockPlace(lng, lngDecimal, lat, latDecimal);
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

    // Bit packs 4 geo location uints together into single uint
    function placeIdFromBlockPlace(uint256 lng, uint256 lngDecimal, uint256 lat, uint256 latDecimal) public pure returns (uint256) {
        validateBlockPlace(lng, lngDecimal, lat, latDecimal);
        uint256 uint256_1 = lng << 26; // values < 360. use 16 bits
        uint256 uint256_2 = lat << 18; // values < 180. use 8 bits
        uint256 uint256_3 = lngDecimal << 10; // values < 100. use 8 bits
        uint256 uint256_4 = latDecimal << 2; // values < 100. use 8 bits
        uint256 patternCode = uint256_1 | uint256_2 | uint256_3 | uint256_4;
        return patternCode | 3;  // Ensuring the last two bits are 1
    }

    // Unpack a bit packed block id into 4 geo location uints
    function blockPlaceFromPlaceId(uint256 _placeId) public pure returns (bool isValid, uint lng, uint lngDecimal, uint lat, uint latDecimal) {
        // Ensure the last two bits are set to 1
        if((_placeId & 3) != 3) {
            return(false, 0, 0, 0, 0);
        }

        // Ensure there is not extra bits in front
        if (_placeId > 24139107727) {
            return(false, 0, 0, 0, 0);
        }

        // Shift the values out of the correct positions
        uint16 lngSrc = uint16(_placeId >> 26);
        uint8 latSrc = uint8(_placeId >> 18);
        uint8 lngDecimalSrc = uint8(_placeId >> 10);
        uint8 latDecimalSrc = uint8(_placeId >> 2);
        if (isValidBlockPlace(lngSrc, lngDecimalSrc, latSrc, latDecimalSrc) > 0) {
            return(false, 0, 0, 0, 0);
        }

        isValid = true;
        lng = uint(lngSrc);
        lngDecimal = uint(lngDecimalSrc);
        lat = uint(latSrc);
        latDecimal = uint(latDecimalSrc);
    }

    function placeIdForLngLat(int lng, uint lngDecimal, int lat, uint latDecimal) public pure returns (uint256) {
        int paddedLng = lng + 180;
        int paddedLat = lat + 90;
        if (paddedLng < 0) {
            revert ValMustBeGtZero(paddedLng);
        }
        if (paddedLat < 0) {
            revert ValMustBeGtZero(paddedLat);
        }
        return placeIdFromBlockPlace(uint(paddedLng), lngDecimal, uint(paddedLat), latDecimal);
    }

    function southwestCornerOfPlaceId(uint256 placeId) public pure returns (int lng, uint lngDecimal, int lat, uint latDecimal) {
        (bool isValid, uint lngSrc, uint lngDecimalSrc, uint latSrc, uint latDecimalSrc) = blockPlaceFromPlaceId(placeId);
        if (!isValid) {
            return (0, 0, 0, 0);
        }
        int paddedLng = int(lngSrc) - 180;
        int paddedLat = int(latSrc) - 90;
        return (paddedLng, lngDecimalSrc, paddedLat, latDecimalSrc);
    }

    function placeIdsInSquare(uint256 northWestPlaceId, uint256 size) public view returns (uint256[] memory) {
        (bool isValid, uint lngOrigin, uint lngDecimalOrigin, uint latOrigin, uint latDecimalOrigin) = blockPlaceFromPlaceId(northWestPlaceId);
        if (!isValid) {
            revert InvalidPlaceId();
        }
        if (size < 1) {
            revert InvalidSquareRegion();
        }
        if ((int(latOrigin) * 100) + int(latDecimalOrigin) - int(size) < 0) {
            revert InvalidSquareRegion();
        }
        if ((lngOrigin * 100) + lngDecimalOrigin + size > 36000) {
            revert InvalidSquareRegion();
        }
        console.log("Origin Place ");
        console.log(lngOrigin);
        console.log(lngDecimalOrigin);
        console.log(latOrigin);
        console.log(latDecimalOrigin);
        uint256[] memory placeIds = new uint256[](size * size);
        uint256 placeId;
        for (uint i = 0; i < size; i++) {
            for (uint j = 0; j < size; j++) {
                uint expandedLng = (lngOrigin * 100) + lngDecimalOrigin + j;
                uint currLng = expandedLng / 100;
                uint currLngDecimal = expandedLng % 100;
                uint expandedLat = (latOrigin * 100) + latDecimalOrigin - i;
                uint currLat = expandedLat / 100;
                uint currLatDecimal = expandedLat % 100;
                console.log("GOT HERE 1");
                console.log( currLng);
                console.log( currLngDecimal);
                console.log( currLat);
                console.log( currLatDecimal);
                console.log("GOT HERE 2");
                placeId = placeIdFromBlockPlace(currLng, currLngDecimal, currLat, currLatDecimal);
                placeIds[i * size + j] = placeId;
            }
        }
        return placeIds;
    }

}
