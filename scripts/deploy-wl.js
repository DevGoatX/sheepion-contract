const hre = require('hardhat');

const Config = require('../config');

async function main(){
    const {ethers} = hre;
    const networkName = hre.hardhatArguments.network ?? hre.config.defaultNetwork;

    const whitelistTokenMetaUri = Config.wlTokenMetaUri;

    const WhiltelistContract = await ethers.getContractFactory('SheepionWL');  
    console.log("Token has been created.");

    const whitelistToken = await WhiltelistContract.deploy(whitelistTokenMetaUri);
    await whitelistToken.deployed();
    
    console.log("Whtelist Token has been deployed.");

    console.log('------------------ Tokens Deployed ----------------');
    console.log('Whitelist Token:', whitelistToken.address);
    console.log('------------------Verify Whitelist Token------------------------');
    console.log(`npx hardhat verify --network ${networkName}`, whitelistToken.address, whitelistTokenMetaUri);
    console.log('------------------------------------------------------------------------------------');
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
