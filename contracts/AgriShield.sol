// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./AgriShieldNFT.sol";
import "./InsuranceEnums.sol";
import "./InsuranceStructs.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV2V3Interface.sol";

contract AgriShield {
    address dataFeedStorePrecipitation;
    address dataFeedStoreSnowfall;
    AgriShieldNFT public nft;

    constructor(address _dataFeedStorePrecipitation, address _dataFeedStoreSnowfall) {
        dataFeedStorePrecipitation = _dataFeedStorePrecipitation;
        dataFeedStoreSnowfall = _dataFeedStoreSnowfall;
        nft = new AgriShieldNFT();
    }

    function mint(uint256 startDate, uint256 endDate, InsuranceEnums.InsuranceType insuranceType) external payable {
        require(insuranceType != InsuranceEnums.InsuranceType.NONE, "insurance type should not be 0");
        require(endDate > startDate, "endDate should be after startDate");
        uint256 requiredPayment = getRequiredPayment(startDate, endDate);
        require(msg.value >= requiredPayment, "Insufficient ETH sent for the specified duration");
        // generate prepopulated traits for nft based on type
        nft.mint(msg.sender, InsuranceStructs.InsurancePolicy(insuranceType, 0, 0, startDate, endDate));
    }

    function getRequiredPayment(uint256 startDate, uint256 endDate) public pure returns (uint256) {
        require(endDate > startDate, "endDate should be after startDate");
        uint256 numberOfDays = (endDate - startDate) / 1 days;
        return numberOfDays * 0.01 ether;
    }

    function claim(uint256 tokenId) external {
        require(nft.ownerOf(tokenId) == msg.sender, "not the owner of this token");

        // Retrieve the insurance policy associated with the tokenId
        InsuranceStructs.InsurancePolicy memory policy = nft.getInsurancePolicy(tokenId);

        require(policy.insuranceType != InsuranceEnums.InsuranceType.NONE, "no insurance policy for this token");
        require(policy.endDate < block.timestamp, "endDate has not passed");

        bool shouldBePaidOut = false;
        uint256 totalPrecipitation = 0;
        uint256 totalSnowfall = 0;

        // Determine which type of insurance to evaluate
        if (policy.insuranceType == InsuranceEnums.InsuranceType.DROUGHT) {
            // Fetch precipitation data from the oracle
            totalPrecipitation = getPrecipitationData(policy.startDate, policy.endDate);

            // Check if precipitation is below a certain threshold for drought
            if (totalPrecipitation < policy.precipitation) {
                // Example threshold
                shouldBePaidOut = true;
            }
        } else if (policy.insuranceType == InsuranceEnums.InsuranceType.RAINY) {
            // Fetch precipitation data from the oracle
            totalPrecipitation = getPrecipitationData(policy.startDate, policy.endDate);

            // Check if precipitation is above a certain threshold for rainfall
            if (totalPrecipitation > policy.precipitation) {
                // Example threshold
                shouldBePaidOut = true;
            }
        } else if (policy.insuranceType == InsuranceEnums.InsuranceType.SNOWFALL) {
            // Fetch snowfall data from the oracle
            totalSnowfall = getSnowfallData(policy.startDate, policy.endDate);

            // Check if snowfall is above a certain threshold for snowfall
            if (totalSnowfall > policy.snowfall) {
                // Example threshold
                shouldBePaidOut = true;
            }
        }

        if (shouldBePaidOut) {
            // Calculate the payout amount (e.g., 100 times the required payment)
            uint256 payoutAmount = getRequiredPayment(policy.startDate, policy.endDate) * 100;
            console.log("Balance: ", address(this).balance);
            require(address(this).balance >= payoutAmount, "Insufficient contract balance for payout");

            // Transfer the payout to the claimer
            (bool success,) = msg.sender.call{value: payoutAmount}("");
            require(success, "Failed to transfer ETH to claimer");
        }

        // Burn the NFT as the claim has been processed
        nft.burn(tokenId);
    }

    function getNftAddress() external view returns (address) {
        return address(nft);
    }

    /**
     * @dev Fetches precipitation data from the oracle for the given date range.
     * Implements early termination if the round timestamp is after endDate.
     * Utilizes binary search for efficient data retrieval in large date ranges.
     * @param startDate The start date of the policy period.
     * @param endDate The end date of the policy period.
     * @return totalPrecipitation The total precipitation over the period.
     */
    function getPrecipitationData(uint256 startDate, uint256 endDate)
        internal
        view
        returns (uint256 totalPrecipitation)
    {
        uint80 latestRound = getLatestRound(dataFeedStorePrecipitation);
        uint80 firstRelevantRound = findFirstRound(startDate, latestRound);

        for (uint80 roundId = firstRelevantRound; roundId > 0; roundId--) {
            (, int256 answer,, uint256 timestamp,) = AggregatorV2V3Interface(dataFeedStorePrecipitation).getRoundData(roundId);

            if (timestamp > endDate) {
                // Skip rounds after the endDate
                continue;
            }

            if (timestamp < startDate) {
                // No more relevant data
                break;
            }

            totalPrecipitation += uint256(answer);
        }
    }

    /**
     * @dev Performs a binary search to find the first round ID that is on or after the startDate.
     * @param startDate The start date of the policy period.
     * @param latestRound The latest round ID available from the oracle.
     * @return firstRound The first round ID that meets the criteria.
     */
    function findFirstRound(uint256 startDate, uint80 latestRound) internal view returns (uint80 firstRound) {
        uint80 low = 1;
        uint80 high = latestRound;
        firstRound = latestRound;

        while (low <= high) {
            uint80 mid = low + (high - low) / 2;
            (,,, uint256 timestamp,) = AggregatorV2V3Interface(dataFeedStorePrecipitation).getRoundData(mid);

            if (timestamp < startDate) {
                low = mid + 1;
            } else {
                firstRound = mid;
                high = mid - 1;
            }
        }
    }

    /**
     * @dev Fetches snowfall data from the oracle for the given date range.
     * @param startDate The start date of the policy period.
     * @param endDate The end date of the policy period.
     * @return totalSnowfall The total snowfall over the period.
     */
    function getSnowfallData(uint256 startDate, uint256 endDate) internal view returns (uint256 totalSnowfall) {
        // Example implementation: Replace with actual oracle data fetching logic
        // This could involve looping through each day in the range and summing the snowfall
        uint80 latestRound = getLatestRound(dataFeedStoreSnowfall);
        for (uint80 roundId = latestRound; roundId > 0; roundId--) {
            (uint80 id, int256 answer,, uint256 timestamp,) =
                AggregatorV2V3Interface(dataFeedStoreSnowfall).getRoundData(roundId);
            if (timestamp < startDate) {
                break;
            }
            totalSnowfall += uint256(answer);
        }
    }

    /**
     * @dev Retrieves the latest round ID from the oracle.
     * @return latestRound The latest round ID.
     */
    function getLatestRound(address _dataStore) internal view returns (uint80 latestRound) {
        latestRound = uint80(AggregatorV2V3Interface(_dataStore).latestRound());
    }

    function receive() external payable {
        console.log("called receive");
    }
}
