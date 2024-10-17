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
      const [owner, otherAccount] = await ethers.getSigners();
      // Define your mnemonic phrase
      const mnemonic = "test test test test test test test test test test test junk";
      // const mnemonic = "announce room limb pattern dry unit scale effort smooth jazz weasel alcohol"
      const wallet = ethers.Wallet.fromPhrase(mnemonic)

      try {
        const address = await wallet.address;
        const balance = await wallet.balance;

        console.log("Wallet Address:", address);
        // console.log("Wallet Balance (ETH):", ethers.utils.formatEther(balance));
      } catch (error) {
        console.log("Error fetching wallet info:", error);
      }
      const AgriShield = await ethers.getContractFactory("AgriShield");

      // 0x5Af511e3BE3E4A672A7a8CB20271a741CF12CE68 // Chainlink proxy BTC/USD - used for precipitation
      // TODO will be used for snowfall
      // 0xF20807e060e5790f75567311313FDdfCe2d898dc // Chainlink proxy ETH/USD
      const agriShieldContract = await AgriShield.deploy("0x5Af511e3BE3E4A672A7a8CB20271a741CF12CE68");
      await agriShieldContract.mint(1726602202, 1728330202, 0, { value: BigInt(1_000_000_000_000_000_000) });

      const nftFactory = await ethers.getContractFactory("AgriShieldNFT");
      const nft = await nftFactory.attach(await agriShieldContract.getNftAddress());
      console.log("Owner of nft: ", await nft.ownerOf(0));

      // await AgriShield.connect(owner).deploy("0xeE5a4826068C5326a7f06fD6c7cBf816F096846c")
      // const MyContract = await ethers.getContractFactory("MyContract");
      // const contractAddress = "0xc04b335A75C5Fa14246152178f6834E3eBc2DC7C";
      // // const contractABI = [{ "inputs": [{ "internalType": "address", "name": "_logic", "type": "address" }, { "internalType": "address", "name": "_owner", "type": "address" }], "stateMutability": "nonpayable", "type": "constructor" }, { "inputs": [{ "internalType": "address", "name": "implementation", "type": "address" }], "name": "InvalidImplementation", "type": "error" }, { "inputs": [], "name": "ProxyDeniedAdminAccess", "type": "error" }, { "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "implementation", "type": "address" }], "name": "Upgraded", "type": "event" }, { "stateMutability": "payable", "type": "fallback" }];
      // const lockContract = new ethers.Contract(contractAddress, contractABI, ethers.provider);
      // // Example: Calling a read-only function (view function)
      // // const result = await contractAddress();
      // console.log(lockContract.address);
      // const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

      // expect(await lock.unlockTime()).to.equal(unlockTime);
    });

    // it("Should set the right owner", async function () {
    //   const { lock, owner } = await loadFixture(deployOneYearLockFixture);

    //   expect(await lock.owner()).to.equal(owner.address);
    // });
  })
});
