// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";

contract GasSnapshot is Script {
    string public constant SNAP_DIR = ".forge-snapshots/";

    uint256 internal cachedGas;
    string internal cachedName;

    function snapStart(string memory name) internal {
        cachedName = name;
        cachedGas = gasleft() - 22100; // subtract sstore cost
    }

    function snapEnd() internal {
        uint256 newGasLeft = gasleft();
        uint256 gasUsed = cachedGas - newGasLeft;
        string[] memory writeSnapshot = new string[](4);
        writeSnapshot[0] = "./write-snapshot.sh";
        writeSnapshot[1] =
            string(abi.encodePacked(SNAP_DIR, cachedName, ".snap"));
        writeSnapshot[2] = vm.toString(gasUsed);
        vm.ffi(writeSnapshot);

        // reset to 0 so all writes are cold for consistent overhead handling
        cachedGas = 0;
    }
}
