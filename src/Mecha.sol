/// SPDX-License-Identifier: MIT
/**
 *    References:
 *        https://github.com/nibbstack/erc721/blob/master/src/contracts/tokens/nf-token.sol
 *        https://ethereum.org/pt-br/developers/docs/standards/tokens/erc-721/#body
 *        https://eips.ethereum.org/EIPS/eip-721#motivation
 */ pragma solidity ^0.8.0;

import "./SupportsInterface.sol";
import "./utils/erc721.sol";
import "./utils/erc721-token-receiver.sol";

/// @title Mecha NFT Collection
/// @notice Mecha NFTs that contain random attributes
contract Mecha is ERC721, SupportsInterface {
    string public name = "Mecha";
    string public symbol = "MCH";

    /**
     * @dev Magic value of a smart contract that can receive NFT.
     * Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
     */
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    /// @notice Attributes ment to give different aspects to a Mecha, the higher the better
    /// @param strength The strenght of the Mecha
    /// @param health The health of the Mecha
    /// @param speed The speed of the Mecha
    struct MechaAttributes {
        uint8 strength;
        uint8 health;
        uint8 speed;
    }

    uint256 private _nextTokenId = 1;
    uint256 private _activeTokens = 0;
    uint256 public constant MINT_PRICE = 0.001 ether;

    /// @dev A mapping from NFT ID to the address that owns it.
    mapping(uint256 => address) internal idToOwner;

    /// @dev Mapping from NFT ID to approved address.
    mapping(uint256 => address) internal idToApproval;

    /// @dev Mapping from owner address to count of their tokens.
    mapping(address => uint256) private ownerToNfTokenCount;

    /// @dev Mapping from owner address to mapping of operator addresses.
    mapping(address => mapping(address => bool)) internal ownerToOperators;

    /// @dev Mapping from Mecha id to MechaAttributes
    mapping(uint256 => MechaAttributes) internal idToAttributes;

    /// @dev Contract constructor.
    constructor() {
        /// 0x80ac58cd = ERC721
        supportedInterfaces[0x80ac58cd] = true;
    }

    /// @notice Emitted when a new Mecha NFT is created
    /// @param minter Address that minted the NFT
    /// @param tokenId ID of the minted token
    /// @param strength The strenght atribute value
    /// @param health The health atribute value
    /// @param speed The speed atribute value
    /// @param mintPrice Current price of the NFT when minted
    event MechaMinted(
        address indexed minter, uint256 indexed tokenId, uint8 strength, uint8 health, uint8 speed, uint256 mintPrice
    );

    error InvalidTransfer(address from, address to);
    error InvalidNewOwner(address invalidNewOwner);
    error InvalidAddress(address invalidAddress);
    error InvalidOwner(address invalidOwner);

    /**
     * @dev Guarantees that the msg.sender is allowed to transfer NFT.
     * @param _tokenId ID of the NFT to transfer.
     */
    modifier canTransfer(uint256 _tokenId) {
        _canTransfer(_tokenId);
        _;
    }

    /**
     * @dev Guarantees that _tokenId is a valid Token.
     * @param _tokenId ID of the NFT to validate.
     */
    modifier validNfToken(uint256 _tokenId) {
        _validNfToken(_tokenId);
        _;
    }

    function _validNfToken(uint256 _tokenId) internal view {
        require(idToOwner[_tokenId] != address(0), "NFT no valid");
    }

    /**
     * @dev Codesize optimization hence modifier can be used in more than one place
     */
    function _canTransfer(uint256 _tokenId) internal view {
        address _owner = idToOwner[_tokenId];
        require(
            msg.sender == _owner || msg.sender == idToApproval[_tokenId] || ownerToOperators[_owner][msg.sender],
            "Not owner, approved or operator"
        );
    }

    /**
     * @notice The actual transfers are made from this function, in order
     *   to centralize logic and reduce bugs. Thus, no need for modifiers related to
     *   transferences in logics that call _transfer()
     * @dev Actually performs the transfer.
     * @param _from Address of the current owner.
     * @param _to Address of a new owner.
     * @param _tokenId The NFT that is being transferred.
     */
    function _transfer(address _from, address _to, uint256 _tokenId)
        private
        canTransfer(_tokenId)
        validNfToken(_tokenId)
    {
        address _owner = idToOwner[_tokenId];
        if (_from != _owner) revert InvalidOwner(_owner);
        if (_to == address(0)) revert InvalidNewOwner(_to);
        if (_from == _to) revert InvalidTransfer(_from, _to);

        // updates ownership
        idToOwner[_tokenId] = _to;

        // updates ntf counters
        ownerToNfTokenCount[_from] -= 1;
        ownerToNfTokenCount[_to] += 1;

        delete idToApproval[_tokenId];

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Actually perform the safeTransferFrom.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     * @param _data Additional data with no specified format, sent in call to `_to`.
     */
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private {
        _transfer(_from, _to, _tokenId);

        if (_to.code.length > 0) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(retval == MAGIC_ON_ERC721_RECEIVED, "Unable to receive NFT");
        }
    }

    /**
     * @notice Throws if _owner is equal to zero address
     * @dev Get the amount of NFTs an address has
     * @param _owner The owner address
     * @return uint256 The amount of NFTs the address owns
     */
    function balanceOf(address _owner) external view returns (uint256) {
        if (_owner == address(0)) revert InvalidAddress(_owner);
        return ownerToNfTokenCount[_owner];
    }

    /**
     * @notice Find the owner of an NFT
     * @dev Reverts if token doesn't exist (owner is address(0))
     * @param _tokenId The token Id
     * @return _owner Token owner address
     */
    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = idToOwner[_tokenId];
        if (_owner == address(0)) revert InvalidOwner(_owner);
    }

    /**
     * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
     * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
     * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
     * function checks if `_to` is a smart contract (code size > 0). If so, it calls
     * `onERC721Received` on `_to` and throws if the return value is not
     * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
     * @dev Transfers the ownership of an NFT from one address to another address.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     * @param _data Additional data with no specified format, sent in call to `_to`.
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) external override {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev This works identically to the other function with an extra data parameter,
     *  except this function just sets data to "".
     * @param _from The current owner of the NFT
     * @param _to The new owner
     * @param _tokenId The NFT to transfer
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
     * they may be permanently lost.
     * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
     * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
     * address. Throws if `_tokenId` is not a valid NFT.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        _transfer(_from, _to, _tokenId);
    }

    /**
     * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
     * the current NFT owner, or an authorized operator of the current owner.
     * @dev Set or reaffirm the approved address for an NFT. This function can be changed to payable.
     * @param _approved The new approved NFT controller.
     * @param _tokenId The NFT to approve.
     */
    function approve(address _approved, uint256 _tokenId) external validNfToken(_tokenId) {
        address _owner = idToOwner[_tokenId];
        require(_approved != _owner, "Approval to current owner");
        require(
            msg.sender == _owner || ownerToOperators[_owner][msg.sender], "Sender not allowed to perform this action"
        );

        idToApproval[_tokenId] = _approved;

        emit Approval(_owner, _approved, _tokenId);
    }

    /**
     * @notice The contract MUST allow multiple operators per owner.
     * @dev Enables or disables approval for a third party ("operator") to manage all of
     * `msg.sender`'s assets. It also emits the ApprovalForAll event.
     * @param _operator Address to add to the set of authorized operators.
     * @param _approved True if the operators is approved, false to revoke approval.
     */
    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender, "Cannot approve self");
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @notice Throws if `_tokenId` is not a valid NFT.
     * @dev Get the approved address for a single NFT.
     * @param _tokenId The NFT to find the approved address for.
     * @return Address that _tokenId is approved for.
     */
    function getApproved(uint256 _tokenId) external view validNfToken(_tokenId) returns (address) {
        return idToApproval[_tokenId];
    }

    /**
     * @dev Checks if `_operator` is an approved operator for `_owner`.
     * @param _owner The address that owns the NFTs.
     * @param _operator The address that acts on behalf of the owner.
     * @return True if approved for all, false otherwise.
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return ownerToOperators[_owner][_operator];
    }

    /// @dev WARNING: Uses pseudo-randomness. NOT secure for production. For learning purposes only
    ///      Miners can manipulate. Replace with Chainlink VRF before mainnet.
    function _generateRandomNumber(uint256 tokenId, string memory trait) private view returns (uint8) {
        uint256 randomHash = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId, trait)));

        return uint8((randomHash % 99) + 1); // 1-99
    }

    /**
     * @notice Function that mints new NFTs at MINT_PRICE
     * @return tokenId The id of the recently created token
     */
    function mint() external payable returns (uint256 tokenId) {
        require(msg.value == MINT_PRICE, "Invalid amount of ether");

        tokenId = _nextTokenId;
        MechaAttributes memory attributes = MechaAttributes({
            strength: _generateRandomNumber(tokenId, "strength"),
            health: _generateRandomNumber(tokenId, "health"),
            speed: _generateRandomNumber(tokenId, "speed")
        });

        idToOwner[tokenId] = msg.sender;
        ownerToNfTokenCount[msg.sender] += 1;
        idToAttributes[tokenId] = attributes;

        _nextTokenId += 1;
        _activeTokens += 1;

        emit Transfer(address(0), msg.sender, tokenId);
        emit MechaMinted(msg.sender, tokenId, attributes.strength, attributes.health, attributes.speed, MINT_PRICE);
    }

    /**
     * @notice Permanently destroys a Mecha NFT
     *   @dev Burns the token by transferring to address(0). Only the owner can burn.
     *      Emits Transfer event. Attributes are preserved for historical data.
     *   @param tokenId The ID of the Mecha to burn
     */
    function burn(uint256 tokenId) external {
        address owner = idToOwner[tokenId];

        require(owner != address(0), "Token doesn't exist");
        require(msg.sender == owner, "Not owner");

        delete idToOwner[tokenId];
        ownerToNfTokenCount[owner] -= 1;
        delete idToApproval[tokenId];
        delete idToAttributes[tokenId];

        _activeTokens -= 1;

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @notice Get the attributes of a Mecha
     *   @dev Returns attributes for any not burned tokenId
     *        Does not validate if token exists
     *   @param tokenId The ID of the Mecha to query
     *   @return attributes The Mecha's strength, health, and speed attributes
     */
    function getAttributes(uint256 tokenId) external view returns (MechaAttributes memory) {
        return idToAttributes[tokenId];
    }

    function getActiveTokens() external view returns (uint256) {
        return _activeTokens;
    }
}
