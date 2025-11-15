/// SPDX-License-Identifier: MIT
/** 
*    References: 
*        https://github.com/nibbstack/erc721/blob/master/src/contracts/tokens/nf-token.sol
*        https://ethereum.org/pt-br/developers/docs/standards/tokens/erc-721/#body
*        https://eips.ethereum.org/EIPS/eip-721#motivation
*/ 
pragma solidity ^0.8.0;

import "./utils/erc721.sol";
import "./SupportsInterface.sol";

/// @title Mecha NFT Collection
/// @notice Mecha NFTs that contain random attributes
contract Mecha is 
    ERC721,
    SupportsInterface
{
    /// @notice Attributes ment to give different aspects to a Mecha, the higher the better
    /// @param strength The strenght of the Mecha
    /// @param health The health of the Mecha
    /// @param speed The speed of the Mecha
    struct MechaAttributes {
        uint8 strength,
        uint8 health,
        uint8 speed
    }

    uint256 private _nextTokenId = 1;
    uint256 public constant MINT_PRICE = 0.001 ether;

    /// @dev A mapping from NFT ID to the address that owns it.
    mapping (uint256 => address) internal idToOwner;

    /// @dev Mapping from NFT ID to approved address.
    mapping (uint256 => address) internal idToApproval;

    /// @dev Mapping from owner address to count of their tokens.
    mapping (address => uint256) private ownerToNFTokenCount;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping (address => mapping (address => bool)) internal ownerToOperators;

    /// @dev Mapping from Mecha id to MechaAttributes
    mapping (uint256 => MechaAttributes) internal idToAttributes;

      /**
   * @dev Contract constructor.
   */
    constructor() {
        /// 0x80ac58cd = ERC721
        supportedInterfaces[0x80ac58cd] = true;
    }

    /// @notice Emitted when ownership of an NFT changes
    /// @dev Required by the ERC-721 specification.
    /// @param _from Source address (address(0) if minting)
    /// @param _to Destination address (address(0) if burning)
    /// @param _tokenId ID of the transferred token
    event Transfer(
        address indexed _from, 
        address indexed _to, 
        uint256 indexed _tokenId
    );

    /// @notice Emitted when an address is granted permission to operate a specific NFT
    /// @dev Required by the ERC-721 specification.
    /// @param _owner Current owner of the NFT
    /// @param _approved Address that received approval (or address(0) to remove)
    /// @param _tokenId ID of the approved token
    event Approval(
        address indexed _owner, 
        address indexed _approved, 
        uint256 indexed _tokenId
    );

    /// @notice Emitted when an operator is approved or unapproved to manage all NFTs of an owner
    /// @dev Required by the ERC-721 specification.
    /// @param _owner Owner of the NFTs
    /// @param _operator Address of the operator
    /// @param _approved True to grant permission, false to revoke
    event ApprovalForAll(
        address indexed _owner, 
        address indexed _operator, 
        bool _approved
    );

    /// @dev Throws invalid address error
    error InvalidAddress(address invalidAddress);

    /**
    * @notice Throws if _owner is equal to zero address
    * @dev Get the amount of NFTs an address has
    * @param _owner The owner address
    * @return uint256 The amount of NFTs the address owns
    */
    function balanceOf(address _owner) external view returns (uint256) {
        if (_owner != address(0)) revert InvalidAddress(_owner);
        returns ownerToNFTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}