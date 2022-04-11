// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "./SheepionWL.sol";

/**
 * @title SheepionNFT
 * SheepionNFT - ERC721 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract SheepionNFT is ERC721A, Ownable {
  
  // base uri
  string private baseURI;

  address payable private walletMaster = payable({{WALLET_MASTER}});
  address payable constant public walletDev = payable({{WALLET_DEV}});

  address private wlContractAddress;

  event MintedNFT(address _owner, uint256 _collectionId, uint256 startId, uint256 _amount);
  event MintedBatchNFT(address _owner, uint256[] _collectionIds, uint256 startId, uint256[] _amounts);

  constructor(address _wlContractAddress, string memory _uri) ERC721A("{{NFT_NAME}}", "{{NFT_SYMBOL}}") {
    wlContractAddress = _wlContractAddress;
    baseURI = _uri;
  }

  /**
  * Require msg.sender to be the master
  */
  modifier onlyMaster() {
    require(isMaster(msg.sender), "Sheepion NFT: You are not a Master");
    _;
  }

  /**
  * get account is master or not
  * @param _account address
  * @return true or false
  */
  function isMaster(address _account) public view returns (bool) {
    return walletMaster == payable(_account) || walletDev == payable(_account);
  }

  /**
   * Will update the base URL of token's URI
   * @param _newBaseURI New base URL of token's URI
   */
  function setBaseURI(string memory _newBaseURI) public onlyMaster {
    baseURI = _newBaseURI;
  }

  /**
   * get base uri 
   * @return base uri
   */
  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  /**
    * start token id should be 1
    */
  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }

  /**
  * get whitelist contract address
  * @return whitelist contract address
  */
  function getWLContractAddress() public view returns (address) {
    return wlContractAddress;
  }

  /**
  * set whitelist contract address
  * @param _wlContractAddress whitelist contract address
  */
  function setWLContractAddress(address _wlContractAddress) public onlyMaster {
    wlContractAddress = _wlContractAddress;
  }

  /**
  * change ownership for whitelist contract address
  * @param _newAddress new owner address of whitelist contract
  */
  function changeOwnershipOfWLToken(address _newAddress) public onlyMaster {
    SheepionWL(wlContractAddress).transferOwnership(_newAddress);
  }

  /**
  * get token id list of owner
  * @param _owner the owner of token
  * @return token id list
  */
  function getTokenIdsOfOwner(address _owner) public view returns (uint256[] memory) {
    uint256 tokenCounter = 0;

    unchecked {
      // get counter of tokens
      for (uint256 i = _startTokenId(); i < _currentIndex; i++) {
        if (ownerOf(i) == _owner) {
          tokenCounter++;
        }
      }

      // configure token id list
      uint256[] memory tokenIds = new uint256[](tokenCounter);
      uint8 index = 0;
      for (uint256 i = _startTokenId(); i < _currentIndex; i++) {
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
  ) external {
    console.log('------ mint/sender: ', msg.sender);
    require(SheepionWL(wlContractAddress).balanceOf(msg.sender, _wlCollectionId) >= _quantity, "Sheepion NFT: You have not enough whitelist token balance to mint NFT");
    
    uint256 startId = _currentIndex;

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
  ) external {
    console.log('------ mintBatch/sender: ', msg.sender);

    require(_wlCollectionIds.length > 0, "Sheepion NFT: The whitelist collection id array should not be empty");
    require(_wlCollectionIds.length == _quantities.length, "Sheepion NFT: The lengths of the whitelist collection id array and amount array should be the same");

    uint256 totalQuantity = 0;
    for (uint16 i = 0; i < _wlCollectionIds.length; i++) {
      require(0 < _wlCollectionIds[i] && _wlCollectionIds[i] < 4, "Sheepion NFT: The whitelist collection id should be in the range of 1 to 3");
      require(SheepionWL(wlContractAddress).balanceOf(msg.sender, _wlCollectionIds[i]) >= _quantities[i], "Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      totalQuantity += _quantities[i] * 5;
    }

    uint256 startId = _currentIndex;
    
    _safeMint(msg.sender, totalQuantity, "");

    console.log('------ mintBatch/safe minted ');    
    // burn wl tokens as quantity
    SheepionWL(wlContractAddress).burnBatch(msg.sender, _wlCollectionIds, _quantities);

    emit MintedBatchNFT(msg.sender, _wlCollectionIds, startId, _quantities);
  }
}
