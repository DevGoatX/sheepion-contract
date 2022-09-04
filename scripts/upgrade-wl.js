
const { ethers, upgrades } = require('hardhat');

const Config = require('../config');

async function main(){    
    const deployedWLTokenAddress = Config.deployedWLTokenAddress;
    const networkName = hre.hardhatArguments.network ?? hre.config.defaultNetwork;
    
    const WhiltelistContract = await ethers.getContractFactory('SheepionWL');    
    console.log("Whitelist Token have been created.");

    const whitelistToken = await upgrades.upgradeProxy(deployedWLTokenAddress, WhiltelistContract);
    console.log("Whitelist Token has been upgraded.");

    console.log('Whitelist Token Address:', whitelistToken.address);
    console.log('------------------Verify Whitelist Token------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, whitelistToken.address);
    console.log('------------------------------------------------------------------------------------');
}


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
