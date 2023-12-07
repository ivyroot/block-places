// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/BlockPlaces.sol";

contract BlockPlacesTest is Test {

    function testCannotDecodeZero() public {
        (bool found,,,,) = BlockPlaces.lngLatFromPlaceId(0);
        assertEq(found, false);
    }

    // test location all zeros
    function testEncodeLocation0() public {
        uint testResult = BlockPlaces.placeIdFromLngLat(0, 0, 0, 0);
        assertEq(testResult, 3);
    }

    function testDecodeLocation0() public {
        (bool found, uint long, uint longOffset, uint lat, uint latOffset) = BlockPlaces.lngLatFromPlaceId(3);
        assertEq(found, true);
        assertEq(lat, 0);
        assertEq(latOffset, 0);
        assertEq(long, 0);
        assertEq(longOffset, 0);
    }

    // test location all max values
    function testEncodeLocationMax() public {
        uint testResult = BlockPlaces.placeIdFromLngLat(359, 99, 179, 99);
        assertEq(testResult, 24118218127);
    }

    function testDecodeLocationMax() public {
        (bool found, uint long, uint longOffset, uint lat, uint latOffset) = BlockPlaces.lngLatFromPlaceId(24118218127);
        assertEq(found, true);
        assertEq(long, 359);
        assertEq(longOffset, 99);
        assertEq(lat, 179);
        assertEq(latOffset, 99);
    }

    function testCannotDecodeAboveLocationMax() public {
        (bool found,,,,) = BlockPlaces.lngLatFromPlaceId(24118218127 + 1);
        assertEq(found, false);
    }

    function testCannotDecodeWayAboveLocationMax() public {
        uint extraDataPlaceId = 3 + (1 << 50);
        (bool found,,,,) = BlockPlaces.lngLatFromPlaceId(extraDataPlaceId);
        assertEq(found, false);
    }

    function testEncodeLocation1() public {
        // hollywood sign
        uint testResult = BlockPlaces.placeIdFromLngLat(118, 32, 34, 14);
        assertEq(testResult, 7927269435);
    }

    function testDecodeLocation1() public {
        (bool found, uint long, uint longOffset, uint lat, uint latOffset) = BlockPlaces.lngLatFromPlaceId(7927269435);
        assertEq(found, true);
        assertEq(long, 118);
        assertEq(longOffset, 32);
        assertEq(lat, 34);
        assertEq(latOffset, 14);
    }

    function testValidateLat() public {
        vm.expectRevert();
        BlockPlaces.placeIdFromLngLat(118, 32, 180, 13);
    }

    function testValidateLatDecimal() public {
        vm.expectRevert();
        BlockPlaces.placeIdFromLngLat(118, 32, 170, 100);
    }

    function testValidateLong() public {
        vm.expectRevert();
        BlockPlaces.placeIdFromLngLat(361, 32, 170, 34);
    }

    function testValidateLongDecimal() public {
        vm.expectRevert();
        BlockPlaces.placeIdFromLngLat(118, 100, 170, 13);
    }

}

