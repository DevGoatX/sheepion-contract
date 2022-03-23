const { expect } = require("chai");
const { ethers } = require("hardhat");

const Config = require('../config');

describe("Integrating", function () {

  let Token;
  let wlToken;
  let sheepionNFT;
  let addr1;
  let addr2;
  let addrs;

  const weiUnit = 1000000000000000000;
  const _boosterMintFee = BigInt(Config.boosterMintFee * weiUnit);
  const _battleMintFee = BigInt(Config.battleMintFee * weiUnit);
  const _herdMintFee = BigInt(Config.herdMintFee * weiUnit);

  beforeEach(async function() {

    [owner, addr1, addr2] = await ethers.getSigners();

    const whitelistTokenMetaUri = Config.wlTokenMetaUri;

    const WLToken = await ethers.getContractFactory("SheepionWL");
    wlToken = await WLToken.deploy(whitelistTokenMetaUri);
    await wlToken.deployed();
    console.log('------ whitelist contract deployed: ', wlToken.address);

    const NFT = await ethers.getContractFactory("SheepionNFT");
    sheepionNFT = await NFT.deploy(wlToken.address);
    await sheepionNFT.deployed();
    console.log('------ NFT contract deployed: ', sheepionNFT.address);

    // TransferOwnership to Sale Contract
    const txWhitelistToken = await wlToken.transferOwnership(sheepionNFT.address);
    await txWhitelistToken;
    console.log('------ whitelist token owner: ', sheepionNFT.address);
  });

  // whitelist token part
  describe("Whitelist Token Testing", function() {

    it("WL mint function", async function () {
      console.log('address 1 balance: ', await ethers.provider.getBalance(addr1.address));
  
      await expect( 
        wlToken.connect(addr1).mint(0, 2, {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");
  
      await expect( 
        wlToken.connect(addr1).mint(4, 2, {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");
  
      await expect( 
        wlToken.connect(addr1).mint(1, 2, {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");

      let amount = 2;
      await expect( 
        wlToken.connect(addr1).mint(1, amount, {value: _boosterMintFee * BigInt(amount) - BigInt(1)})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");

      await expect( 
        wlToken.connect(addr1).mint(2, amount, {value: _battleMintFee * BigInt(amount) - BigInt(1)})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");
  
      const mintTx = await wlToken.connect(addr1).mint(1, amount, {value: _boosterMintFee * BigInt(amount)});
      await mintTx.wait();
  
      expect(await wlToken.totalMinted()).to.equal(2);
    });
  
    it("WL mintBatch function", async function () {
      console.log('address 1 balance: ', await ethers.provider.getBalance(addr1.address));
  
      await expect( 
        wlToken.connect(addr1).mintBatch([0, 1], [2, 0], {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");
  
      await expect( 
        wlToken.connect(addr1).mintBatch([4, 1], [2, 1], {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: The collection id should be in the range of 1 to 3");
  
      await expect( 
        wlToken.connect(addr1).mintBatch([1, 2], [2, 3], {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");

      await expect( 
        wlToken.connect(addr1).mintBatch([1, 2], [2, 3], {value: 0})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");

      await expect( 
        wlToken.connect(addr1).mintBatch([1, 2], [2, 3], {value: _boosterMintFee * BigInt(2) + _battleMintFee * BigInt(3) - BigInt(1)})
      ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");
  
      const mintTx = await wlToken.connect(addr1).mintBatch([1, 2, 3], [2, 1, 3], 
        {value: _boosterMintFee * BigInt(2) + _battleMintFee + _herdMintFee * BigInt(3)}
      );
      await mintTx.wait();
  
      expect(await wlToken.balanceOf(addr1.address, 1)).to.equal(2);
      expect(await wlToken.balanceOf(addr1.address, 2)).to.equal(1);
      expect(await wlToken.balanceOf(addr1.address, 3)).to.equal(3);
      expect(await wlToken.totalMinted()).to.equal(6);
    });

  })

  // nft part
  describe("NFT Part", function() {

    beforeEach(async function() {
      const mintTx = await wlToken.connect(addr1).mintBatch([1, 2, 3], [2, 1, 3], 
        {value: _boosterMintFee * BigInt(2) + _battleMintFee + _herdMintFee * BigInt(3)}
      );
      await mintTx.wait();
    });

    it("NFT mint function", async function () {
      console.log('NFT contract address: ', sheepionNFT.address);
      console.log('whitelist contract address: ', await sheepionNFT.getWLContractAddress());

      await expect( 
        sheepionNFT.connect(addr1).mint(0, 3)
      ).to.be.revertedWith("Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      await expect( 
        sheepionNFT.connect(addr1).mint(1, 3)
      ).to.be.revertedWith("Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      await expect( 
        sheepionNFT.connect(addr1).mint(3, 4)
      ).to.be.revertedWith("Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      // await expect( 
      //   wlToken.connect(addr1).mint([1, 2], [2, 3], {value: _boosterMintFee * BigInt(2) + _battleMintFee * BigInt(3) - BigInt(1)})
      // ).to.be.revertedWith("Sheepion Whitelist Token: Not enough Matic sent");

      let mintTx = await sheepionNFT.connect(addr1).mint(1, 1);
      await mintTx.wait();

      mintTx = await sheepionNFT.connect(addr1).mint(3, 2);
      await mintTx.wait();

      expect(await wlToken.totalMinted()).to.equal(6);

      expect(await wlToken.balanceOf(addr1.address, 1)).to.equal(1);
      expect(await wlToken.balanceOf(addr1.address, 2)).to.equal(1);
      expect(await wlToken.balanceOf(addr1.address, 3)).to.equal(1);
      expect(await wlToken.totalSupply()).to.equal(3);
    });

    it("NFT mintBatch function", async function () {
      console.log('NFT contract address: ', sheepionNFT.address);
      console.log('whitelist contract address: ', await sheepionNFT.getWLContractAddress());

      await expect( 
        sheepionNFT.connect(addr1).mintBatch([], [1, 1])
      ).to.be.revertedWith("Sheepion NFT: The whitelist collection id array should not be empty");

      await expect( 
        sheepionNFT.connect(addr1).mintBatch([1], [1, 1])
      ).to.be.revertedWith("Sheepion NFT: The lengths of the whitelist collection id array and amount array should be the same");

      await expect( 
        sheepionNFT.connect(addr1).mintBatch([0, 1], [1, 1])
      ).to.be.revertedWith("Sheepion NFT: The whitelist collection id should be in the range of 1 to 3");

      await expect( 
        sheepionNFT.connect(addr1).mintBatch([1, 2], [3, 1])
      ).to.be.revertedWith("Sheepion NFT: You have not enough whitelist token balance to mint NFT");

      let mintTx = await sheepionNFT.connect(addr1).mintBatch([1, 2], [1, 1]);
      await mintTx.wait();

      expect(await wlToken.totalMinted()).to.equal(6);
      expect(await wlToken.totalSupply()).to.equal(4);
      expect(await sheepionNFT.totalSupply()).to.equal(10);
      

      mintTx = await sheepionNFT.connect(addr1).mintBatch([3, 1], [2, 1]);
      await mintTx.wait();

      expect(await wlToken.totalMinted()).to.equal(6);
      expect(await wlToken.totalSupply()).to.equal(1);
      expect(await sheepionNFT.totalSupply()).to.equal(25);
      expect(await wlToken.balanceOf(addr1.address, 1)).to.equal(0);
      expect(await wlToken.balanceOf(addr1.address, 2)).to.equal(0);
      expect(await wlToken.balanceOf(addr1.address, 3)).to.equal(1);
    });
  });
});
