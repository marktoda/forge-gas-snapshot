// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {GasSnapshot} from "../GasSnapshot.sol";

contract GasTests is GasSnapshot {
    uint256 internal test;
    string internal prefix;

    constructor(string memory _prefix) {
        prefix = _prefix;
    }

    function small() external {
        snapStart(string(abi.encodePacked(prefix, "small")));
        uint256 x = 1;
        x++;
        snapEnd();
    }

    function medium() external {
        snapStart(string(abi.encodePacked(prefix, "medium")));
        uint256 x;
        for (uint256 i = 0; i < 100; i++) {
            x = i + 1;
        }
        snapEnd();
    }

    function large() external {
        snapStart(string(abi.encodePacked(prefix, "large")));
        for (uint256 i = 0; i < 100; i++) {
            test = i + 2;
        }
        snapEnd();
    }
}
