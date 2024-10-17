// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./InsuranceEnums.sol";
import "./InsuranceStructs.sol";

contract AgriShieldNFT is Ownable, ERC721 {
    uint256 public tokenCounter;

    // Mapping from tokenId to insurance policies
    mapping(uint256 => InsuranceStructs.InsurancePolicy) public insurancePolicies;

    constructor() Ownable(msg.sender) ERC721("AgriShield NFT", "ASH") {
        tokenCounter = 0;
    }

    // Function to receive payments and mint an NFT
    function mint(address receiver, InsuranceStructs.InsurancePolicy memory _insurancePolicy) external onlyOwner {
        // Mint the NFT to the sender
        uint256 newTokenId = tokenCounter;

        // Record the payment details
        insurancePolicies[newTokenId] = _insurancePolicy;

        tokenCounter++;
        _safeMint(receiver, newTokenId);
    }

    function burn(uint256 _tokenId) external onlyOwner {
        _burn(_tokenId);
    }
}
