// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/BlockPlaces.sol";

contract BlockPlacesTest is Test {
    // hollywood sign
    uint256 public constant hollywoodSign = 4126216247;
    uint256 public constant placeIdCloseToSouthPole = 12079595531;
    uint256 public constant placeIdCloseToPrimeMeridian = 24115775491;

    error valueNotFoundInArray(uint256 search);

    function assertUintInArray(uint256 search, uint256[] memory results) pure public {
        for (uint i = 0; i < results.length; i++) {
            if (results[i] == search) {
                return;
            }
        }
        revert valueNotFoundInArray(search);
    }


    function testLocation1IsValid() public {
        (bool isValid, , , , ) = BlockPlaces.blockPlaceFromPlaceId(hollywoodSign);
        assertTrue(isValid);
    }

    function testSquareSize0Location1() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(hollywoodSign, 0);
    }

    function testSquareSize1Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 1);
        assertEq(results.length, 1);
        assertEq(results[0], hollywoodSign);
    }

    function testSquareSize2Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 2);
        assertEq(results.length, 4);
        assertUintInArray(hollywoodSign, results);
        assertUintInArray(4126217271, results);
        assertUintInArray(4126217267, results);
        assertUintInArray(4126216243, results);
    }

    function testSquareSize3Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 3);
        assertEq(results.length, 9);
        assertUintInArray(hollywoodSign, results);
        assertUintInArray(4126217271, results);
        assertUintInArray(4126218295, results);
        assertUintInArray(4126217267, results);
        assertUintInArray(4126216243, results);
        assertUintInArray(4126218291, results);
        assertUintInArray(4126216239, results);
        assertUintInArray(4126217263, results);
        assertUintInArray(4126218287, results);
    }

    function testSquareSize4Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 4);
        assertEq(results.length, 16);
        // same as 3
        assertUintInArray(hollywoodSign, results);
        assertUintInArray(4126217271, results);
        assertUintInArray(4126218295, results);
        assertUintInArray(4126217267, results);
        assertUintInArray(4126216243, results);
        assertUintInArray(4126218291, results);
        assertUintInArray(4126216239, results);
        assertUintInArray(4126217263, results);
        assertUintInArray(4126218287, results);
        // outer ring
        assertUintInArray(4126219319, results);
        assertUintInArray(4126219315, results);
        assertUintInArray(4126219311, results);
        assertUintInArray(4126219307, results);
        assertUintInArray(4126218283, results);
        assertUintInArray(4126217259, results);
        assertUintInArray(4126216235, results);
    }

    // test square regions cannot go off bottom of earth
    function testSquareSize1NearSouthPole() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(placeIdCloseToSouthPole, 1);
        assertEq(results.length, 1);
        assertEq(results[0], placeIdCloseToSouthPole);
    }

    function testSquareSize2NearSouthPole() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(placeIdCloseToSouthPole, 2);
        assertEq(results.length, 4);
        assertEq(results[0], placeIdCloseToSouthPole);
    }
    function testSquareSize3LocationNearSouthPole() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToSouthPole, 3);
    }
    function testSquareSize4LocationNearSouthPole() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToSouthPole, 4);
    }
    function testSquareSize5LocationNearSouthPole() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToSouthPole, 5);
    }

    // test square regions cannot go across the prime meridian
    function testSquareSize1LocationNearPrimeMeridian() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(placeIdCloseToPrimeMeridian, 1);
        assertEq(results.length, 1);
        assertEq(results[0], placeIdCloseToPrimeMeridian);
    }
    function testSquareSize2LocationNearPrimeMeridian() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(placeIdCloseToPrimeMeridian, 2);
        assertEq(results.length, 4);
        assertEq(results[0], placeIdCloseToPrimeMeridian);
    }
    function testSquareSize3LocationNearPrimeMeridian() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToPrimeMeridian, 3);
    }
    function testSquareSize4LocationNearPrimeMeridian() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToPrimeMeridian, 4);
    }
    function testSquareSize5LocationNearPrimeMeridian() public {
        vm.expectRevert();
        BlockPlaces.placeIdsInSquare(placeIdCloseToPrimeMeridian, 5);
    }

}