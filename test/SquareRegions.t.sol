// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "../src/BlockPlaces.sol";

contract BlockPlacesTest is Test {
    // hollywood sign
    uint256 public constant hollywoodSign = 4126216247;

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

    function testSquareSize1Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 1);
        assertEq(results[0], hollywoodSign);
        assertEq(results.length, 1);
    }

    function testSquareSize2Location1() public {
        uint[] memory results = BlockPlaces.placeIdsInSquare(hollywoodSign, 2);
        assertEq(results.length, 4);
        assertUintInArray(hollywoodSign, results);
        assertUintInArray(4126217271, results);
        assertUintInArray(4126217267, results);
        assertUintInArray(4126216243, results);
    }

}