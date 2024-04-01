// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/console2.sol";
import {Script} from "forge-std/Script.sol";
import {UintString} from "./utils/UintString.sol";

contract GasSnapshot is Script {
    error GasMismatch(uint256 oldGas, uint256 newGas);

    /// @notice if this environment variable is true, we revert on gas mismatch
    string public constant CHECK_ENV_VAR = "FORGE_SNAPSHOT_CHECK";
    /// @notice save gas snapshots in this dir
    string public constant SNAP_DIR = ".forge-snapshots/";
    /// @notice temporary env variable to help with string parsing
    string private constant TEMP_ENV_VAR = "_forge_snapshot_temp_gas";
    /// @notice gas overhead for the snapshotting function itself
    uint256 private constant GAS_CALIBRATION = 100;

    /// @notice if true, revert on gas mismatch, else overwrite with new values
    bool internal check;
    /// @notice Transient variable for the start gas
    uint256 private cachedGas;
    /// @notice Transient variable for the snapshot name
    string private cachedName;

    constructor() {
        _mkdirp(SNAP_DIR);
        try vm.envBool(CHECK_ENV_VAR) returns (bool _check) {
            check = _check;
        } catch {
            check = false;
        }
    }

    /// @notice Write a size snapshot with the given name
    /// @param target the contract to snapshot the size of
    /// @dev The next call to `snapEnd` will end the snapshot
    function snapSize(string memory name, address target) internal {
        uint256 size = target.code.length;

        _checkOrWriteSnapshot(name, size);
    }

    /// @notice Snapshot the given value
    function snap(string memory name, uint256 value) internal {
        _checkOrWriteSnapshot(name, value);
    }

    /// @notice Snapshot the given external closure
    /// @dev most accurate as storage cost semantics are not involved
    function snap(string memory name, function() external fn) internal {
        uint256 gasBefore = gasleft();
        fn();
        uint256 gasUsed = gasBefore - gasleft();

        _checkOrWriteSnapshot(name, gasUsed);
    }

    /// @notice Snapshot the given internal closure
    /// @dev most accurate as storage cost semantics are not involved
    function snap(string memory name, function() internal fn) internal {
        uint256 gasBefore = gasleft();
        fn();
        uint256 gasUsed = gasBefore - gasleft();

        _checkOrWriteSnapshot(name, gasUsed);
    }

    /// @notice Start a snapshot with the given name
    /// @dev The next call to `snapEnd` will end the snapshot
    function snapStart(string memory name) internal {
        // warm up cachedGas so the only sstore after calling `gasleft` is exactly 100 gas
        cachedGas = 1;
        cachedName = name;
        cachedGas = gasleft();
    }

    /// @notice End the current snapshot
    /// @dev Must be called after a call to `snapStart`, else reverts with underflow
    function snapEnd() internal {
        uint256 newGasLeft = gasleft();
        // subtract original gas and snapshot gas overhead
        uint256 gasUsed = cachedGas - newGasLeft - GAS_CALIBRATION;
        // reset to 0 so all writes for consistent overhead handling
        cachedGas = 0;

        _checkOrWriteSnapshot(cachedName, gasUsed);
    }

    /// @notice Check the gas usage against the snapshot. Revert on mismatch
    function _checkSnapshot(string memory name, uint256 gasUsed) internal view {
        uint256 oldGasUsed = _readSnapshot(name);
        if (oldGasUsed != gasUsed) {
            revert GasMismatch(oldGasUsed, gasUsed);
        }
    }

    /// @notice Read the last snapshot value from the file
    function _readSnapshot(string memory name) private view returns (uint256 res) {
        string memory oldValue = vm.readLine(_getSnapFile(name));
        res = UintString.stringToUint(oldValue);
    }

    /// @notice Write the new snapshot value to file
    function _writeSnapshot(string memory name, uint256 gasUsed) private {
        vm.writeFile(_getSnapFile(name), vm.toString(gasUsed));
    }

    /// @notice Make the directory for snapshots
    function _mkdirp(string memory dir) private {
        string[] memory mkdirp = new string[](3);
        mkdirp[0] = "mkdir";
        mkdirp[1] = "-p";
        mkdirp[2] = dir;
        vm.ffi(mkdirp);
    }

    /// @notice Get the snapshot file name
    function _getSnapFile(string memory name) private pure returns (string memory) {
        return string(abi.encodePacked(SNAP_DIR, name, ".snap"));
    }

    /// @notice Return if the snapshot file exists
    function _snapshotFileExists(string memory name) private returns (bool) {
        string[] memory command = new string[](2);
        command[0] = "cat";
        command[1] = _getSnapFile(name);

        bytes memory result = vm.ffi(command);

        return bytes32(result) != bytes32(0);
    }

    /// @notice Execute the check or write the snapshot based on the requirements
    function _checkOrWriteSnapshot(string memory name, uint256 gasUsed) private {
        if (check && _snapshotFileExists(name)) return _checkSnapshot(name, gasUsed);
        _writeSnapshot(name, gasUsed);
    }

    /// @notice sets the library to check mode
    function setCheckMode(bool _check) internal {
        check = _check;
    }
}
