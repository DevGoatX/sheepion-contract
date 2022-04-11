const hre = require('hardhat');

const Config = require('../config');

async function main(){
    const {ethers} = hre;
    const networkName = hre.hardhatArguments.network ?? hre.config.defaultNetwork;
    const wlTokenAddress = Config.wlTokenAddress;
    const nftBaseUri = Config.nftBaseUri;
    
    const NFTContract = await ethers.getContractFactory('SheepionNFT');
    
    console.log("Tokens have been created.");

    const nftToken = await NFTContract.deploy(wlTokenAddress, nftBaseUri);
    await nftToken.deployed();

    console.log("NFT Token has been deployed.");

    console.log('------------------ Tokens Deployed ----------------');
    console.log('NFT Token :', nftToken.address);
    console.log('------------------Verify NFT------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, nftToken.address, wlTokenAddress, nftBaseUri);
    console.log('------------------------------------------------------------------------------------');
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
