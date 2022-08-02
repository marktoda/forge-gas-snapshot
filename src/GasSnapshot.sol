// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";

contract GasSnapshot is Script {
    string public constant SNAP_DIR = ".forge-snapshots/";

    uint256 internal cachedGas;
    string internal cachedName;

    constructor() {
        _mkdirp(SNAP_DIR);
    }

    function snapStart(string memory name) internal {
        cachedName = name;
        cachedGas = gasleft() - 22100; // subtract sstore cost
    }

    function snapEnd() internal {
        uint256 newGasLeft = gasleft();
        uint256 gasUsed = cachedGas - newGasLeft;
        // reset to 0 so all writes are cold for consistent overhead handling
        cachedGas = 0;

        _writeSnapshot(cachedName, gasUsed);
    }

    function _writeSnapshot(string memory name, uint256 gasUsed) private {
        string[] memory writeSnapshot = new string[](3);
        string memory fileName = string(abi.encodePacked(SNAP_DIR, name, ".snap"));
        writeSnapshot[0] = "sh";
        writeSnapshot[1] = "-c";
        writeSnapshot[2] = string(abi.encodePacked("echo -n ", vm.toString(gasUsed), " > ", fileName));
        vm.ffi(writeSnapshot);
    }

    function _mkdirp(string memory dir) private {
        string[] memory mkdirp = new string[](3);
        mkdirp[0] = "mkdir";
        mkdirp[1] = "-p";
        mkdirp[2] = dir;
        vm.ffi(mkdirp);
    }
}
