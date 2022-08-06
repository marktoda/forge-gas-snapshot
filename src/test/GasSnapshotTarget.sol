// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract GasSnapshotTarget {
    uint256 internal test;
    string internal prefix;

    constructor(string memory _prefix) {
        prefix = _prefix;
    }

    function add() external {
        uint256 x = 1;
        x++;
    }

    function manyAdd() external {
        uint256 x;
        for (uint256 i = 0; i < 100; i++) {
            x = i + 1;
        }
    }

    function manySstore() external {
        for (uint256 i = 0; i < 100; i++) {
            test = i + 2;
        }
    }
}
