const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Test", function () {

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      // const localProvider = new ethers.JsonRpcProvider("http://127.0.0.1:8546");
      // Define your mnemonic phrase
      const mnemonic = "test test test test test test test test test test test junk";
      // const mnemonic = "announce room limb pattern dry unit scale effort smooth jazz weasel alcohol"
      const localProvider = new ethers.JsonRpcProvider("http://localhost:8545");
      let wallet = ethers.Wallet.fromPhrase(mnemonic);
      const [owner, otherAccount] = await ethers.getSigners();
      try {
        const [owner, otherAccount] = await ethers.getSigners();
        await otherAccount.sendTransaction({
          to: owner.address,
          value: ethers.parseEther("100")
        })
      } catch (error) {
        console.log("Error fetching wallet info:", error);
      }
      const AgriShield = await ethers.getContractFactory("AgriShield");

      // 0x5Af511e3BE3E4A672A7a8CB20271a741CF12CE68 // Chainlink proxy BTC/USD - used for precipitation
      // TODO will be used for snowfall
      // 0xF20807e060e5790f75567311313FDdfCe2d898dc // Chainlink proxy ETH/USD
      const agriShieldContract = await AgriShield.deploy("0x5Af511e3BE3E4A672A7a8CB20271a741CF12CE68");
      await agriShieldContract.mint(1726602202, 1728330202, 1, { value: ethers.parseEther("0.2") });

      const nftFactory = await ethers.getContractFactory("AgriShieldNFT");
      const nft = await nftFactory.attach(await agriShieldContract.getNftAddress());
      console.log("Owner of nft: ", await nft.ownerOf(0));

      await agriShieldContract.connect(otherAccount).receive({ value: ethers.parseEther("100") });
      console.log(await ethers.provider.getBalance(agriShieldContract));
      await agriShieldContract.claim(0);
      // console.log(await ethers.provider.getBlock('latest'));

      // currentBlock: 6897494 timestamp: 1729243800

      // next day: 1729243800 + 715700
      // 1729250957
      // curl -X POST --data '{"jsonrpc":"2.0","method":"anvil_setNextBlockTimestamp","params":[1729250957],"id":1}' -H "Content-Type: application/json" http://localhost:8545
    });
  })
});
