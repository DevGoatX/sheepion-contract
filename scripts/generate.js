const dayjs = require('dayjs');
const Joi = require('joi');
const {ethers} = require('ethers');
require('dotenv').config();
const fs = require('fs');

const schema = Joi.object({
    WALLET_MASTER: Joi.string().trim().required().pattern(/^0x[a-fA-F0-9]{40}$/).required(),
    WALLET_DEV: Joi.string().trim().required().pattern(/^0x[a-fA-F0-9]{40}$/).required(),

    WLTOKEN_NAME: Joi.string().trim().required(),
    WLTOKEN_SYMBOL: Joi.string().trim().uppercase().required(),
    BOOSTER_MINT_FEE: Joi.number().greater(0).required(),
    BATTLE_MINT_FEE: Joi.number().greater(0).required(),
    HERD_MINT_FEE: Joi.number().greater(0).required(),
    
    NFT_NAME: Joi.string().trim().required(),
    NFT_SYMBOL: Joi.string().trim().uppercase().required(),
});

const templatePath = 'templates';
const contractsPath = 'contracts';
try {
    // Validate
    const {value, error} = schema.validate(process.env, {stripUnknown: true});
    console.log(value);
    if (error) {
        console.log(`Error on parameters validation ${error}`);
        return;
    }

    try {
        fs.unlinkSync(`${contractsPath}/SheepionWL.sol`);
    } catch (error) {
        console.log('delete SheepionWL.sol error: ', error);
    }
    try {
        fs.unlinkSync(`${contractsPath}/SheepionNFT.sol`);
    } catch (error) {
        console.log('delete SheepionNFT.sol error: ', error);
    }
    console.log(`all files were deleted ----------`);

    const { WALLET_MASTER, WALLET_DEV, WALLET_ARTIST, 
            WLTOKEN_NAME, WLTOKEN_SYMBOL, BOOSTER_MINT_FEE, BATTLE_MINT_FEE, HERD_MINT_FEE, 
            NFT_NAME, NFT_SYMBOL, 
        } = value;

    // Write SheepionWL.sol
    let fileName = "SheepionWL.sol";
    let content = fs.readFileSync(`${templatePath}/${fileName}`, 'utf8');
    content = content
        .replace(new RegExp("{{WLTOKEN_NAME}}", 'g'), WLTOKEN_NAME)
        .replace(new RegExp("{{WLTOKEN_SYMBOL}}", 'g'), WLTOKEN_SYMBOL)
        .replace(new RegExp("{{WALLET_MASTER}}", 'g'), WALLET_MASTER)
        .replace(new RegExp("{{BOOSTER_MINT_FEE}}", 'g'), BOOSTER_MINT_FEE)
        .replace(new RegExp('{{BATTLE_MINT_FEE}}', 'g'), BATTLE_MINT_FEE)
        .replace(new RegExp('{{HERD_MINT_FEE}}', 'g'), HERD_MINT_FEE);

    fs.writeFileSync(`${contractsPath}/${fileName}`, content, 'utf-8');
    console.log(`${fileName} Generated----------`);

    // Write SheepionNFT.sol
    fileName = "SheepionNFT.sol";
    content = fs.readFileSync(`${templatePath}/${fileName}`, 'utf8');
    
    content = content
        .replace(new RegExp("{{NFT_NAME}}", 'g'), NFT_NAME)
        .replace(new RegExp("{{NFT_SYMBOL}}", 'g'), NFT_SYMBOL)
        .replace(new RegExp("{{WALLET_MASTER}}", 'g'), WALLET_MASTER)
        .replace(new RegExp("{{WALLET_DEV}}", 'g'), WALLET_DEV);

    fs.writeFileSync(`${contractsPath}/${fileName}`, content, 'utf-8');
    console.log(`${fileName} Generated----------`);

} catch(error) {
    console.log(`Error in Generation: ${error}`);
}

