// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GasTests} from "../src/test/GasTests.sol";

contract GasSnapshotTest is Test {
    GasTests gasTests;

    function setUp() public {
        gasTests = new GasTests();
    }

    function testSmall() public {
        gasTests.small();
        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/small.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "22211");
    }

    function testMedium() public {
        gasTests.medium();
        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/medium.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "40769");
    }

    function testLarge() public {
        gasTests.large();
        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/large.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "72566");
    }
}
