// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";

contract Snapshot is Script{
    uint256 internal cachedGas;

    function snapStart() internal {
        cachedGas = gasleft();
    }

    function snapEnd() internal {
        uint256 gasUsed = tx.gasUsed;
    }
}
