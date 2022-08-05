// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {GasSnapshot} from "../src/GasSnapshot.sol";
import {GasTests} from "../src/test/GasTests.sol";

contract GasSnapshotTest is Test {
    GasTests gasTests;

    function setUp() public {
        gasTests = new GasTests("");
    }

    function testSmall() public {
        gasTests.small();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/small.snap";

        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "178");
    }

    function testMedium() public {
        gasTests.medium();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/medium.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "18736");
    }

    function testLarge() public {
        gasTests.large();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/large.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "50533");
    }

    function testCheckMedium() public {
        vm.setEnv("FORGE_SNAPSHOT_CHECK", "true");
        GasTests otherGasTests = new GasTests("snap");
        // preloaded with the right value
        otherGasTests.medium();
    }

    function testCheckLargeFails() public {
        vm.setEnv("FORGE_SNAPSHOT_CHECK", "true");
        GasTests otherGasTests = new GasTests("snap");
        // preloaded with the wrong value
        vm.expectRevert(
            abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 50533)
        );
        otherGasTests.large();
    }
}
