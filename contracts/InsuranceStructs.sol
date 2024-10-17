    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./InsuranceEnums.sol";

contract InsuranceStructs {
    // Struct to hold user payment details and other fields
    struct InsurancePolicy {
        InsuranceEnums.InsuranceType insuranceType;
        uint256 precipitation;
        uint256 snowfall;
        uint256 startDate;
        uint256 endDate;
    }
}
