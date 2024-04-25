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

    function testSingleSstore() public {
        snapStart("singleSstore");
        simpleOperations.singleSstore();
        snapEnd();

        string memory value = vm.readLine(".forge-snapshots/singleSstore.snap");
        assertEq(value, "48459");
    }

    function testSingleSstoreLastCall() public {
        simpleOperations.singleSstore();
        snapLastCall("singleSstoreLastCall");

        string memory value = vm.readLine(".forge-snapshots/singleSstoreLastCall.snap");
        // includes 21,000 overhead for transaction, 20,000 clean SSTORE
        assertEq(value, "43429");
    }

    function testSingleSstoreClosure() public {
        snap("singleSstoreClosure", simpleOperations.singleSstore);

        string memory value = vm.readLine(".forge-snapshots/singleSstoreClosure.snap");
        assertEq(value, "46269");
    }

    function testManySstoreClosure() public {
        snap("sstoreClosure", simpleOperations.manySstore);

        string memory value = vm.readLine(".forge-snapshots/sstoreClosure.snap");
        assertEq(value, "68158");
    }

    function testInternalClosure() public {
        snap("internalClosure", singleSstore);

        string memory value = vm.readLine(".forge-snapshots/internalClosure.snap");
        assertEq(value, "22217");
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
        assertEq(value, "17530");
    }

    function testManySstore() public {
        snapStart("manySstore");
        simpleOperations.manySstore();
        snapEnd();

        string memory value = vm.readLine(".forge-snapshots/manySstore.snap");
        assertEq(value, "70348");
    }

    function testSnapshotCodeSize() public {
        SimpleOperations sizeTarget = new SimpleOperations();
        snapSize("sizeTarget", address(sizeTarget));
        string memory size = vm.readLine(".forge-snapshots/sizeTarget.snap");
        assertEq(size, "349");
    }

    function testSnapshotCheckSize() public {
        setCheckMode(true);
        SimpleOperations sizeTarget = new SimpleOperations();
        snapSize("checkSize", address(sizeTarget));
    }

    function testSnapshotCheckSizeFail() public {
        setCheckMode(true);
        SimpleOperations sizeTarget = new SimpleOperations();
        vm.expectRevert(abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 349));
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
        vm.expectRevert(abi.encodeWithSelector(GasSnapshot.GasMismatch.selector, 1, 73825));
        snapEnd();
    }

    uint256 internal test;

    function singleSstore() public {
        test = block.timestamp + 3;
    }
}
