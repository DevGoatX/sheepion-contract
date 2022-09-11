// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import 'erc721a-upgradeable/contracts/ERC721AUpgradeable.sol';
import "./SheepionWL.sol";

/**
 * @title SheepionNFT
 * SheepionNFT - ERC721 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract SheepionNFT is ERC721AUpgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {
  
  bytes32 public constant MASTER_ROLE = keccak256("MASTER_ROLE");

  // base uri
  string private baseURI;
  address private wlContractAddress;

  uint8 isReveal;

  event MintedNFT(address _owner, uint256 _collectionId, uint256 startId, uint256 _amount);
  event MintedBatchNFT(address _owner, uint256[] _collectionIds, uint256 startId, uint256[] _amounts);

  function initialize(address _wlContractAddress, string memory _uri) initializerERC721A initializer public {
    __ERC721A_init("{{NFT_NAME}}", "{{NFT_SYMBOL}}");
    __AccessControl_init();

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

    wlContractAddress = _wlContractAddress;
    baseURI = _uri;
    
    isReveal = 0;

    _setupRole(MASTER_ROLE, {{WALLET_MASTER}});
    _setupRole(MASTER_ROLE, {{WALLET_DEV}});
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721AUpgradeable, AccessControlUpgradeable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /**
  * change master wallet address
  * @param _account address
  */
  function changeMaster(address _account) public onlyRole(MASTER_ROLE) {
    _revokeRole(MASTER_ROLE, msg.sender);
    _setupRole(MASTER_ROLE, _account);
  }

  /**
  * return true or false
  */
  function isMaster(address _account) public view returns (bool) {
    return hasRole(MASTER_ROLE, _account);
  }

  /**
   * Will update the base URL of token's URI
   * @param _newBaseURI New base URL of token's URI
   */
  function setBaseURI(string memory _newBaseURI) public onlyRole(MASTER_ROLE) {
    baseURI = _newBaseURI;
  }

  /**
   * get base uri 
   * @return base uri
   */
  function _baseURI() internal view override returns (string memory) {
    if (isReveal == 0) return "";

    return baseURI;
  }

  /**
  * get reveal status
  * @return uint8 reveal status
  */
  function getRevealStatus() public view returns (uint8) {
    return isReveal;
  }

  /**
   * Will update the pre reveal URL of tokens
   * @param _isReveal current state is 
   */
  function setRevealStatus(uint8 _isReveal) public onlyRole(MASTER_ROLE) {
    isReveal = _isReveal;
  }


  /**
    * start token id should be 1
    */
  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  /**
  * get whitelist contract address
  * @return address whitelist contract address
  */
  function getWLContractAddress() public view returns (address) {
    return wlContractAddress;
  }

  /**
  * set whitelist contract address
  * @param _wlContractAddress whitelist contract address
  */
  function setWLContractAddress(address _wlContractAddress) public onlyRole(MASTER_ROLE) {
    wlContractAddress = _wlContractAddress;
  }

  /**
  * get token id list of owner
  * @param _owner the owner of token
  * @return uint256[] token id list
  */
  function getTokenIdsOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 tokenCounter = 0;

    unchecked {
      // get counter of tokens
      for (uint256 i = _startTokenId(); i < _nextTokenId(); i++) {
        if (ownerOf(i) == _owner) {
          tokenCounter++;
        }
      }

      // configure token id list
      uint256[] memory tokenIds = new uint256[](tokenCounter);
      uint8 index = 0;
      for (uint256 i = _startTokenId(); i < _nextTokenId(); i++) {
        if (ownerOf(i) == _owner) {
          tokenIds[index] = i;
          index++;
        }
      }
      
      return tokenIds;
    }
  }

  /**
    * mint new NFT tokens with Whitelist Token Id
    * @param _wlCollectionId collection id of wl token that the wallet already minted
    * @param _quantity amount of token
    */
  function mint(
    uint256 _wlCollectionId,
    uint256 _quantity
  ) external nonReentrant {
    console.log('------ mint/sender: ', msg.sender);
    require(SheepionWL(wlContractAddress).balanceOf(msg.sender, _wlCollectionId) >= _quantity, "Sheepion NFT: You have not enough whitelist token balance to mint NFT");
    
    uint256 startId = _nextTokenId();

    _safeMint(msg.sender, _quantity * 5, "");

    console.log('------ mint/safe minted ');

    // burn wl tokens as quantity
    SheepionWL(wlContractAddress).burn(msg.sender, _wlCollectionId, _quantity);

    emit MintedNFT(msg.sender, _wlCollectionId, startId, _quantity);
  }

  /**
    * mint NFT tokens with Whitelist Token Ids
    * @param _wlCollectionIds collection ids of wl token that the wallet already minted
    * @param _quantities amounts of token
    */
  function mintBatch(
    uint256[] memory _wlCollectionIds,
    uint256[] memory _quantities
  ) external nonReentrant {
    console.log('------ mintBatch/sender: ', msg.sender);

    require(_wlCollectionIds.length > 0, "Sheepion NFT: The whitelist collection id array should not be empty");
    require(_wlCollectionIds.length == _quantities.length, "Sheepion NFT: The lengths of the whitelist collection id array and amount array should be the same");

    uint256 totalQuantity = 0;
    for (uint16 i = 0; i < _wlCollectionIds.length; i++) {
      require(0 < _wlCollectionIds[i] && _wlCollectionIds[i] < 4, "Sheepion NFT: The whitelist collection id should be in the range of 1 to 3");
      require(SheepionWL(wlContractAddress).balanceOf(msg.sender, _wlCollectionIds[i]) >= _quantities[i], "Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      totalQuantity += _quantities[i] * 5;
    }

    uint256 startId = _nextTokenId();
    
    _safeMint(msg.sender, totalQuantity, "");

    console.log('------ mintBatch/safe minted ');    
    // burn wl tokens as quantity
    SheepionWL(wlContractAddress).burnBatch(msg.sender, _wlCollectionIds, _quantities);

    emit MintedBatchNFT(msg.sender, _wlCollectionIds, startId, _quantities);
  }
}
