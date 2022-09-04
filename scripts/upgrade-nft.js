
const { ethers, upgrades } = require('hardhat');

const Config = require('../config');

async function main(){    
    const deployedNFTAddress = Config.deployedNFTAddress;
    const networkName = hre.hardhatArguments.network ?? hre.config.defaultNetwork;

    const NFTContract = await ethers.getContractFactory('SheepionNFT');    
    console.log("NFTContract have been created.");

    const nftToken = await upgrades.upgradeProxy(deployedNFTAddress, NFTContract);
    console.log("NFT Token has been upgraded.");
    
    console.log('NFT Token :', nftToken.address);
    console.log('------------------Verify NFT------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, nftToken.address);
    console.log('------------------------------------------------------------------------------------');
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
