// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';

/**
 * @title SheepionWhitelistToken
 * SheepionWhitelistToken - ERC1155 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol()
 */
contract SheepionWL is ERC1155Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

  uint8 public constant BOOSTER_COLLECTION_ID = 1;
  uint8 public constant BATTLE_COLLECTION_ID = 2;
  uint8 public constant HERD_COLLECTION_ID = 3;

  // Contract name
  string public name;

  // Contract symbol
  string public symbol;

  uint256 private totalMints;
  uint256 private totalTokens;

  uint256 private boosterMintFee;
  uint256 private battleMintFee;
  uint256 private herdMintFee;

  address payable private walletMaster;

  string private boosterUri;
  string private battleUri;
  string private herdUri;

  event MintedWLToken(address _owner, uint256 _collectionId, uint256 _amount);
  event MintedBatchWLToken(address _owner, uint256[] _collectionIds, uint256[] _amounts);
  event Burned(address _from, uint256 _collectionId, uint256 _amount);
  event BurnedBatch(address _from, uint256[] _collectionIds, uint256[] _amounts);
  event WithdrawAll();

  function initialize() initializer public {
    __Ownable_init();

    name = "{{WLTOKEN_NAME}}";
    symbol = "{{WLTOKEN_SYMBOL}}";

    totalMints = 0;
    totalTokens = 0;

    boosterMintFee = {{BOOSTER_MINT_FEE}} ether;
    battleMintFee = {{BATTLE_MINT_FEE}} ether;
    herdMintFee = {{HERD_MINT_FEE}} ether;

    walletMaster = payable({{WALLET_MASTER}});
  }

  /**
  * Require msg.sender to be the master or dev team
  */
  modifier onlyMaster() {
    require(isMaster(msg.sender), "Sheepion Whitelist Token: You are not a Master");
    _;
  }

  /**
  * get account is master or not
  * @param _account address
  * @return true or false
  */
  function isMaster(address _account) public view returns (bool) {
    return walletMaster == payable(_account);
  }

  /**
  * change master wallet address
  * @param _account address
  */
  function changeMaster(address _account) public onlyMaster {
    walletMaster = payable(_account);
  }

  /**
  * get token amount
  * @return token amount
  */
  function totalMinted() public view returns (uint256) {
    return totalMints;
  }

  /**
  * get token amount
  * @return token amount
  */
  function totalSupply() public view returns (uint256) {
    return totalTokens;
  }

  /**
  * set booster collection token uri
  * @param _uri token uri
  */
  function setBoosterURI(string memory _uri) public onlyMaster {
    boosterUri = _uri;
  }

  /**
  * set battle collection token uri
  * @param _uri token uri
  */
  function setBattleURI(string memory _uri) public onlyMaster {
    battleUri = _uri;
  }

  /**
  * set herd collection token uri
  * @param _uri token uri
  */
  function setHerdURI(string memory _uri) public onlyMaster {
    herdUri = _uri;
  }

  /**
  * return uri of token
  */
  function uri(uint256 _id) public view override returns (string memory) {
    if (_id == BOOSTER_COLLECTION_ID)   return boosterUri;
    if (_id == BATTLE_COLLECTION_ID)    return battleUri;
    if (_id == HERD_COLLECTION_ID)      return herdUri;
    
    return "";
  }

  /**
  * get booster token mint fee
  * @return boosterMintFee booster mint fee
  */
  function getBoosterMintFee() public view returns (uint256) {
    return boosterMintFee;
  }

  /**
  * set booster token mint fee
  * @param _boosterMintFee booster token mint fee
  */
  function setBoosterMintFee(uint256 _boosterMintFee) public onlyMaster {
    boosterMintFee = _boosterMintFee;
  }

  /**
  * get battle token mint fee
  * @return battleMintFee battle mint fee
  */
  function getBattleMintFee() public view returns (uint256) {
    return battleMintFee;
  }

  /**
  * set battle token mint fee
  * @param _battleMintFee battle token mint fee
  */
  function setBattleMintFee(uint256 _battleMintFee) public onlyMaster {
    battleMintFee = _battleMintFee;
  }

  /**
  * get herd token mint fee
  * @return herdMintFee herd mint fee
  */
  function getHerdMintFee() public view returns (uint256) {
    return herdMintFee;
  }

  /**
  * set herd token mint fee
  * @param _herdMintFee herd token mint fee
  */
  function setHerdMintFee(uint256 _herdMintFee) public onlyMaster {
    herdMintFee = _herdMintFee;
  }

  /**
  * mint whitelist token by collection
  * @param _collectionId collection id
  * @param _amount token amount
  */
  function mint(uint256 _collectionId, uint256 _amount) external payable nonReentrant {
    require(0 < _collectionId && _collectionId < 4, "Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");

    uint256 mintFee = boosterMintFee;
    if (_collectionId == BATTLE_COLLECTION_ID)
      mintFee = battleMintFee;
    else if (_collectionId == HERD_COLLECTION_ID)
      mintFee = herdMintFee;

    console.log('WL mint/address balance:', msg.value);
    console.log('WL mint/required:       ', mintFee * _amount);
    
    if (!isMaster(msg.sender)) {
        require(msg.value > mintFee * _amount - 1, "Sheepion Whitelist Token: Not enough Matic sent");

        // perform mint
        _mint(msg.sender, _collectionId, _amount, '');

        unchecked {
            uint256 fee = mintFee * _amount;

            // return back remain value
            uint256 remainVal = msg.value - fee;
            address payable caller = payable(msg.sender);
            caller.transfer(remainVal);
        }

    } else {   // no price for master wallet
        // perform mint
        _mint(msg.sender, _collectionId, _amount, '');

        // return back the ethers
        address payable caller = payable(msg.sender);
        caller.transfer(msg.value);
    }
        
    unchecked {
      totalMints += _amount;
      totalTokens += _amount;
    }

    emit MintedWLToken(msg.sender, _collectionId, _amount);
  }

  /**
  * mint batch whitelist token by collection
  * @param _collectionIds collection ids
  * @param _amounts token amounts
  */
  function mintBatch(uint256[] memory _collectionIds, uint256[] memory _amounts) external payable nonReentrant {
    require(_collectionIds.length > 0, "Sheepion Whitelist Token: The collection id array should not be empty");
    require(_collectionIds.length == _amounts.length, "Sheepion Whitelist Token: The lengths of the collection id array and amount array should be the same");

    uint256 totalMintFee = 0;
    uint256 totalAmount = 0;
    for (uint16 i = 0; i < _collectionIds.length; i++) {
      require(0 < _collectionIds[i] && _collectionIds[i] < 4, "Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");

      uint256 mintFee = boosterMintFee;
      if (_collectionIds[i] == BATTLE_COLLECTION_ID)
        mintFee = battleMintFee;
      else if (_collectionIds[i] == HERD_COLLECTION_ID)
        mintFee = herdMintFee;

      unchecked {
        totalMintFee += mintFee * _amounts[i];
        totalAmount += _amounts[i];
      }
    }

    console.log('WL mintBatch/address balance:', msg.value);
    console.log('WL mintBatch/required:       ', totalMintFee);
    
    if (!isMaster(msg.sender)) {
        require(msg.value > totalMintFee - 1, "Sheepion Whitelist Token: Not enough Matic sent");

        // perform mint batch
        _mintBatch(msg.sender, _collectionIds, _amounts, '');

        unchecked {
            // return back remain value
            uint256 remainVal = msg.value - totalMintFee;
            address payable caller = payable(msg.sender);
            caller.transfer(remainVal);
        }

    } else {   // no price for master wallet
        // perform mint batch
        _mintBatch(msg.sender, _collectionIds, _amounts, '');

        // return back the ethers
        address payable caller = payable(msg.sender);
        caller.transfer(msg.value);
    }

    unchecked {
      totalMints += totalAmount;
      totalTokens += totalAmount;
    }

    emit MintedBatchWLToken(msg.sender, _collectionIds, _amounts);
  }

  /**
  * burn collection
  * @param _from address to burn
  * @param _collectionId token id
  * @param _amount token amount
  */
  function burn(address _from, uint256 _collectionId, uint256 _amount) public onlyOwner nonReentrant {
    require(0 < _collectionId && _collectionId < 4, "Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");

    _burn(_from, _collectionId, _amount);

    unchecked {
      totalTokens -= _amount;
    }
    console.log('WL burn/total tokens: ', totalTokens);

    emit Burned(_from, _collectionId, _amount);
  }

  /**
  * burn batch token
  * @param _from address to burn
  * @param _collectionIds token id
  * @param _amounts token amount
  */
  function burnBatch(address _from, uint256[] memory _collectionIds, uint256[] memory _amounts) public onlyOwner nonReentrant {
    require(_collectionIds.length > 0, "Sheepion Whitelist Token: The token id array should not be empty");
    require(_collectionIds.length == _amounts.length, "Sheepion Whitelist Token: The lengths of the token id array and amount array should be the same");

    _burnBatch(_from, _collectionIds, _amounts);

    unchecked {
      for (uint16 i = 0; i < _amounts.length; i++) {
        totalTokens -= _amounts[i];
      }
    }
    console.log('WL burnBatch/total tokens: ', totalTokens);   

    emit BurnedBatch(_from, _collectionIds, _amounts);
  }

  /**
  * withdraw balance to only master wallet
  */
  function withdrawAll() external onlyMaster nonReentrant {
    address payable to = payable(msg.sender);
    to.transfer(address(this).balance);

    emit WithdrawAll();
  }
}
