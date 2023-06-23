// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library TextHandler {
    /// @notice Returns the first line of the given UTF8 text.
    /// @dev UTF8 encoding is such that the EOL characters are bytes that do not feature in the multibyte
    /// UTF8 characters, thus allowing us to simply iterate through the string byte per byte.
    /// @param input The text to extract first line from
    /// @return output The extracted line
    function extractFirstLine(string memory input) internal pure returns (string memory output) {
        output = input;
        uint256 addr;
        uint256 len;
        assembly {
            addr := add(output, 0x20)
            len := mload(output)
        }
        uint256 bytePos = 0;
        uint256 char;
        while (bytePos < len) {
            // Load next byte (and the 31 bytes that follow it)
            assembly {
                char := mload(add(addr, bytePos))
            }
            // Remove the trailing 31 bytes
            char >>= 248;
            // Check if the byte is UTF8 EOL character
            if (char == 0x0d || char == 0x0a) {
                // If it is then update the output string length to current position so we truncate the string
                assembly {
                    mstore(output, bytePos)
                }
                break;
            }
            bytePos += 1;
        }
    }
}
