// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/ercs/blob/master/ERCS/erc-721.md;
 *     https://eips.ethereum.org/EIPS/eip-721#simple-summary.
 */
interface ERC721 {
    /// @notice Emitted when ownership of an NFT changes
    /// @dev Required by the ERC-721 specification.
    /// @param _from Source address (address(0) if minting)
    /// @param _to Destination address (address(0) if burning)
    /// @param _tokenId ID of the transferred token
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @notice Emitted when an address is granted permission to operate a specific NFT
    /// @dev Required by the ERC-721 specification.
    /// @param _owner Current owner of the NFT
    /// @param _approved Address that received approval (or address(0) to remove)
    /// @param _tokenId ID of the approved token
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @notice Emitted when an operator is approved or unapproved to manage all NFTs of an owner
    /// @dev Required by the ERC-721 specification.
    /// @param _owner Owner of the NFTs
    /// @param _operator Address of the operator
    /// @param _approved True to grant permission, false to revoke
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
     * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
     * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
     * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
     * function checks if `_to` is a smart contract (code size > 0). If so, it calls
     * `onERC721Received` on `_to` and throws if the return value is not
     * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
     * @dev Transfers the ownership of an NFT from one address to another address. This function can
     * be changed to payable.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     * @param _data Additional data with no specified format, sent in call to `_to`.
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;

    /**
     * @notice This works identically to the other function with an extra data parameter, except this
     * function just sets data to ""
     * @dev Transfers the ownership of an NFT from one address to another address. This function can
     * be changed to payable.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    /**
     * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
     * they may be permanently lost.
     * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
     * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
     * address. Throws if `_tokenId` is not a valid NFT.  This function can be changed to payable.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    /**
     * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
     * the current NFT owner, or an authorized operator of the current owner.
     * @param _approved The new approved NFT controller.
     * @dev Set or reaffirm the approved address for an NFT. This function can be changed to payable.
     * @param _tokenId The NFT to approve.
     */
    function approve(address _approved, uint256 _tokenId) external;

    /**
     * @notice The contract MUST allow multiple operators per owner.
     * @dev Enables or disables approval for a third party ("operator") to manage all of
     * `msg.sender`'s assets. It also emits the ApprovalForAll event.
     * @param _operator Address to add to the set of authorized operators.
     * @param _approved True if the operators is approved, false to revoke approval.
     */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
     * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
     * considered invalid, and this function throws for queries about the zero address.
     * @notice Count all NFTs assigned to an owner.
     * @param _owner Address for whom to query the balance.
     * @return Balance of _owner.
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @notice Find the owner of an NFT.
     * @dev Returns the address of the owner of the NFT. NFTs assigned to the zero address are
     * considered invalid, and queries about them do throw.
     * @param _tokenId The identifier for an NFT.
     * @return Address of _tokenId owner.
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @notice Throws if `_tokenId` is not a valid NFT.
     * @dev Get the approved address for a single NFT.
     * @param _tokenId The NFT to find the approved address for.
     * @return Address that _tokenId is approved for.
     */
    function getApproved(uint256 _tokenId) external view returns (address);

    /**
     * @notice Query if an address is an authorized operator for another address.
     * @dev Returns true if `_operator` is an approved operator for `_owner`, false otherwise.
     * @param _owner The address that owns the NFTs.
     * @param _operator The address that acts on behalf of the owner.
     * @return True if approved for all, false otherwise.
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
