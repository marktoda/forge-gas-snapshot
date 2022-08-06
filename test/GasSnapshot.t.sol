// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {GasSnapshot} from "../src/GasSnapshot.sol";
import {SimpleOperations} from "../src/test/SimpleOperations.sol";
import {SimpleOperationsGas} from "../src/test/SimpleOperationsGas.sol";

contract GasSnapshotTest is Test {
    SimpleOperations simpleOperations;
    SimpleOperationsGas simpleOperationsGas;

    function setUp() public {
        simpleOperationsGas = new SimpleOperationsGas("");
    }

    function testAdd() public {
        simpleOperationsGas.testAddGas();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/add.snap";

        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "134");
    }

    function testManyAdd() public {
        simpleOperationsGas.testManyAddGas();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/manyAdd.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "18695");
    }

    function testManySstore() public {
        simpleOperationsGas.testManySstoreGas();

        string[] memory getSnapshot = new string[](2);
        getSnapshot[0] = "cat";
        getSnapshot[1] = ".forge-snapshots/manySstore.snap";
        bytes memory res = vm.ffi(getSnapshot);
        assertEq(string(res), "50490");
    }

    function testCheckManyAdd() public {
        vm.setEnv("FORGE_SNAPSHOT_CHECK", "true");
        SimpleOperationsGas otherGasTests = new SimpleOperationsGas("snap");
        // preloaded with the right value
        otherGasTests.testManyAddGas();
    }

    function testCheckManySstoreFails() public {
        vm.setEnv("FORGE_SNAPSHOT_CHECK", "true");
        SimpleOperationsGas otherGasTests = new SimpleOperationsGas("snap");
        // preloaded with the wrong value
        vm.expectRevert(
            abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 50490)
        );
        otherGasTests.testManySstoreGas();
    }
}
