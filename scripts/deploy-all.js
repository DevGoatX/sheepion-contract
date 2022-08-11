
const { ethers, upgrades } = require('hardhat');

const Config = require('../config');

async function main(){
    const networkName = hre.hardhatArguments.network ?? hre.config.defaultNetwork;

    const whitelistTokenMetaUri = Config.wlTokenMetaUri;
    const nftBaseUri = Config.nftBaseUri;

    const WhiltelistContract = await ethers.getContractFactory('SheepionWL');
    const NFTContract = await ethers.getContractFactory('SheepionNFT');
    
    console.log("Tokens have been created.");
    
    const whitelistToken = await upgrades.deployProxy(WhiltelistContract, [], { initializer: 'initialize' });
    await whitelistToken.deployed();
    
    console.log("Whtelist Token has been deployed.");

    const nftToken = await upgrades.deployProxy(NFTContract, [whitelistToken.address, nftBaseUri], { initializer: 'initialize' });
    await nftToken.deployed();

    console.log("NFT Token has been deployed.");

    // TransferOwnership to Sale Contract
    const txWhitelistToken = await whitelistToken.transferOwnership(nftToken.address);
    await txWhitelistToken;

    console.log('------------------ Tokens Deployed ----------------');
    console.log('Whitelist Token:', whitelistToken.address);
    console.log('NFT Token :', nftToken.address);
    console.log('------------------Verify Whitelist Token------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, whitelistToken.address);
    console.log('------------------Verify NFT------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, nftToken.address, whitelistToken.address, nftBaseUri);
    console.log('------------------------------------------------------------------------------------');
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
