// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./AgriShieldNFT.sol";
import "./InsuranceEnums.sol";
import "./InsuranceStructs.sol";

contract AgriShield {
    address dataFeedStore;
    AgriShieldNFT public nft;

    constructor(address _dataFeedStore) {
        dataFeedStore = _dataFeedStore;
        nft = new AgriShieldNFT();
    }

    function mint(uint256 startDate, uint256 endDate, InsuranceEnums.InsuranceType insuranceType) external payable {
        require(endDate > startDate, "endDate should be after startDate");
        uint256 numberOfDays = (endDate - startDate) / 1 days;
        uint256 requiredPayment = numberOfDays * 0.01 ether;
        require(msg.value >= requiredPayment, "Insufficient ETH sent for the specified duration");
        // generate prepopulated traits for nft based on type
        nft.mint(msg.sender, InsuranceStructs.InsurancePolicy(insuranceType, 0, 0, 0, 0));
    }

    function claim(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender, "not the owner of this token");
        bool shouldBePaidOut = false;
        // based on the type, decide what oracle price feed with be queried
        // check if under nft.details.precipitation for drought
        // check if above nft.details.precipitation for rainfall
        // check if above nft.details.snowfall for snowfall
        // create mapping of roundIds to {timestamp, price}
        // start looping from latestRound() in dataFeedStore
        // lower the roundId that you pass to getRoundData(uint80 _roundId)
        // with the returned round data check if the timestamp is before the token startDate or after endDate.
        // if not -> add it to the roundIds
        // now do the sum of all precipitations or snowfall, based on the type
        if (shouldBePaidOut) {
            // get start and endDate from insurancePolicy
            // uint256 numberOfDays = (endDate - startDate) / 1 days;
            // uint256 requiredPayment = numberOfDays * 0.01 ether;
            // (bool success,) = msg.sender.call{value: requiredPayment * 100}();
            // require(success, "failed to transfer ETH to claimer");
        }
        nft.burn(tokenId);
    }

    function getNftAddress() external view returns (address) {
        return address(nft);
    }

    // Key is `31` for precipitation values
    function getDataById() internal returns (uint256) {
        (bool success, bytes memory res) = dataFeedStore.call(abi.encodeWithSignature("latestAnswer()"));
        require(success, "not successful call");
        return abi.decode(res, (uint256));
    }
}
