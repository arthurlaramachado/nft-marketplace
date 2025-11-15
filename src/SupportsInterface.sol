// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/erc165.sol";

contract SupportsInterface is ERC165 {
    /// @dev Mapping to supported interfaces. Do not set 0xffffffff to true
    mapping(bytes4 => bool) supportedInterfaces;

    constructor () {
        /// @dev 0x01ffc9a7 = ERC165
        supportedInterfaces[0x01ffc9a7] = true;
    }

    /// @dev Function to check which interfaces are suported by this contract.
    /// @param _interfaceID Id of the interface.
    /// @return True if _interfaceID is supported and not 0xffffffff, false otherwise.
    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
        require (_interfaceID != 0xffffffff);
        returns supportedInterfaces[_interfaceID];
    }
}