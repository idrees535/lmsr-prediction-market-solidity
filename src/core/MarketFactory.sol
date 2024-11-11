// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LMSRPredictionMarket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PredictionMarketPositions.sol"; // Import the ERC-1155 contract

contract MarketFactory is Ownable {
    address[] public activeMarkets;
    PredictionMarketPositions public positions;
    // Mapping to store market titles
    mapping(address => string) public marketTitles; 

    event MarketCreated(address indexed marketAddress,string title);
    event MinterAuthorized(address indexed marketAddress);

    constructor(address _positionsAddress) Ownable(msg.sender) {
        positions = PredictionMarketPositions(_positionsAddress);
    }

    function createMarket(
        uint256 marketId,
        string memory title,
        string[] memory outcomes,
        address oracle,
        uint256 b,
        uint256 duration,
        uint256 feePercent,
        address feeRecipient,
        address tokenAddress,
        uint256 initialFunds 
    ) public {
        // Deploy the LMSRPredictionMarket contract

        LMSRPredictionMarket newMarket = new LMSRPredictionMarket(
            marketId,
            title,            
            outcomes,
            oracle,
            b,
            duration,
            feePercent,
            feeRecipient,             
            tokenAddress,
            initialFunds,        
            address(positions)       
        );

        // Add the new market to the list of active markets
        activeMarkets.push(address(newMarket));
        // Store the market title in the mapping
        marketTitles[address(newMarket)] = title;
        emit MarketCreated(address(newMarket),title);

        if (initialFunds > 0) {
            require(
                IERC20(tokenAddress).transferFrom(msg.sender, address(newMarket), initialFunds),
                "Initial fund transfer failed"
            );
            }   
    }

    function getActiveMarkets() public view returns (address[] memory) {
        return activeMarkets;
    }
}
