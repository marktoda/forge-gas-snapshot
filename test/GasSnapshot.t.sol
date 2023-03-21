// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {GasSnapshot} from "../src/GasSnapshot.sol";
import {SimpleOperations} from "../src/test/SimpleOperations.sol";

contract GasSnapshotTest is Test, GasSnapshot {
    SimpleOperations simpleOperations;

    function setUp() public {
        simpleOperations = new SimpleOperations();
    }

    function testSnapValue() public {
        snap("value", 1234);

        string memory value = vm.readLine(".forge-snapshots/value.snap");
        assertEq(value, "1234");
    }

    function testAdd() public {
        snapStart("add");
        simpleOperations.add();
        snapEnd();

        string memory value = vm.readLine(".forge-snapshots/add.snap");
        assertEq(value, "5247");
    }

    function testAddClosure() public {
        snap("addClosure", simpleOperations.add);

        string memory value = vm.readLine(".forge-snapshots/addClosure.snap");
        assertEq(value, "3060");
    }

    function testSstoreClosure() public {
        snap("sstoreClosure", simpleOperations.manySstore);

        string memory value = vm.readLine(".forge-snapshots/sstoreClosure.snap");
        assertEq(value, "53894");
    }

    function testInternalClosure() public {
        snap("internalClosure", add);

        string memory value = vm.readLine(".forge-snapshots/internalClosure.snap");
        assertEq(value, "19177");
    }

    function testAddTwice() public {
        snapStart("addFirst");
        simpleOperations.add();
        snapEnd();

        snapStart("addSecond");
        simpleOperations.add();
        snapEnd();

        snapStart("addThird");
        simpleOperations.add();
        snapEnd();

        string memory first = vm.readLine(".forge-snapshots/addFirst.snap");
        string memory second = vm.readLine(".forge-snapshots/addSecond.snap");
        string memory third = vm.readLine(".forge-snapshots/addThird.snap");

        assertEq(second, third);
        assertEq(first, "5247");
        assertEq(second, "744");
    }

    function testManyAdd() public {
        snapStart("manyAdd");
        simpleOperations.manyAdd();
        snapEnd();

        string memory value = vm.readLine(".forge-snapshots/manyAdd.snap");
        assertEq(value, "24330");
    }

    function testManySstore() public {
        snapStart("manySstore");
        simpleOperations.manySstore();
        snapEnd();

        string memory value = vm.readLine(".forge-snapshots/manySstore.snap");
        assertEq(value, "56084");
    }

    function testSnapshotCodeSize() public {
        SimpleOperations sizeTarget = new SimpleOperations();
        snapSize("sizeTarget", address(sizeTarget));
        string memory size = vm.readLine(".forge-snapshots/sizeTarget.snap");
        assertEq(size, "303");
    }

    function testSnapshotCheckSize() public {
        setCheckMode(true);
        SimpleOperations sizeTarget = new SimpleOperations();
        snapSize("checkSize", address(sizeTarget));
    }

    function testSnapshotCheckSizeFail() public {
        setCheckMode(true);
        SimpleOperations sizeTarget = new SimpleOperations();
        vm.expectRevert(abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 303));
        snapSize("checkSizeFail", address(sizeTarget));
    }

    function testCheckManyAdd() public {
        setCheckMode(true);
        // preloaded with the right value
        snapStart("checkManyAdd");
        simpleOperations.manyAdd();
        snapEnd();
    }

    function testCheckManySstoreFails() public {
        setCheckMode(true);
        // preloaded with the wrong value
        snapStart("checkManySstore");
        simpleOperations.manySstore();
        vm.expectRevert(abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 59561));
        snapEnd();
    }

    function add() internal pure {
        uint256 x = 0;
        for (uint256 i = 0; i < 100; i++) {
            x += i;
        }
    }
}
