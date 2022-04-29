const AETHR_Marketplace = artifacts.require("AETHR_Marketplace");
const ATH = artifacts.require("ATH");
const UserPool = artifacts.require("UserPool");
const AETHR_Box = artifacts.require("AETHR_Box");
const AETHR_NFT = artifacts.require("AETHR_NFT");


module.exports = async function (deployer) {

  // Deploy ATH
  await deployer.deploy(ATH);

  // Deploy user pool
  await deployer.deploy(UserPool, process.env.STABLE_TOKEN, ATH.address);

  // Deploy box
  await deployer.deploy(
    AETHR_Box,
    process.env.BASE_BOX_URI,
    process.env.STABLE_TOKEN,
    ATH.address,
    UserPool.address
  );

  // Deploy Marketplace
  await deployer.deploy(AETHR_Marketplace, AETHR_Box.address, process.env.STABLE_TOKEN, ATH.address);

  // Deploy NFT
  await deployer.deploy(
    AETHR_NFT,
    process.env.DEFAULT_URI,
    AETHR_Box.address,
    AETHR_Marketplace.address
  );

  
};
