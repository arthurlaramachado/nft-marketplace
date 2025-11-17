// SPDX-License-Identifier: MIT
/**
 *   References
 *        https://eips.ethereum.org/EIPS/eip-165
 *        https://github.com/ethereum/ercs/blob/master/ERCS/erc-721.md
 */
pragma solidity ^0.8.0;

/// @dev Interface that implements the ERC165 standard
interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param _interfaceId The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    /// `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}
