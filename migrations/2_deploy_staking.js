const AETHR_Staking = artifacts.require("AETHR_Staking");
const ATH = artifacts.require("ATH");

module.exports = async function (deployer) {
  // Deploy Staking
  await deployer.deploy(
    AETHR_Staking,
    process.env.STABLE_TOKEN,
    ATH.address,
    "5000000000000000",
    "5000000000000000000000000",
    [30, 30, 30],
    [2000, 3000, 5000]
  );
};
