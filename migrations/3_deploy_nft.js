const LotteryNFT = artifacts.require('LotteryNFT');

module.exports = async function (deployer, network, addresses) {
  // Use deployer to state migration tasks.
  const [admin] = addresses;
  await deployer.deploy(LotteryNFT, 'Royal Cats Lottery Token', 'LCT', { from: admin });
};
