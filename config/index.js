require('dotenv').config();

module.exports = {
    privateKey: process.env.PRIVATE_KEY,
    rpcs: {
        homestead: process.env.MAIN_RPC,
        rinkeby: process.env.RINKEBY_RPC,
        ropsten: process.env.ROPSTEN_RPC,
        potest: process.env.POTEST_RPC,
        pomain: process.env.POMAIN_RPC,
        ganache: process.env.GANACHE_RPC,
        localhost: process.env.LOCAL_RPC,
        local: process.env.LOCAL_RPC,
    },
    proxyRegistryAddress: {
        homestead: '0x52BD82C6B851AdAC6A77BC0F9520e5A062CD9a78',
        rinkeby: '0x52BD82C6B851AdAC6A77BC0F9520e5A062CD9a78',
        hardhat: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
        ropsten: '0x52BD82C6B851AdAC6A77BC0F9520e5A062CD9a78',
        ganache: '0xD8123497BBF62e559d733C7bD088eD7C40729CFa',
        localhost: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
        local: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
    },
    etherscanApiKey: process.env.ETHERSCAN_API_KEY,
    polygonscanApiKey: process.env.POLYGONSCAN_API_KEY,
    walletMaster: process.env.WALLET_MASTER,
    walletDev: process.env.WALLET_DEV,
    wlTokenMetaUri: process.env.WLTOKEN_META_URI,
    nftBaseUri: process.env.NFT_BASE_URI,
    mintFee: process.env.MINT_FEE,
    wlTokenAddress: process.env.WLTOKEN_ADDRESS,
    boosterMintFee: process.env.BOOSTER_MINT_FEE,
    battleMintFee: process.env.BATTLE_MINT_FEE,
    herdMintFee: process.env.HERD_MINT_FEE,
}
