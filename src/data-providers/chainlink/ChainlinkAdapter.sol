/**
 * Adapter for chainlink's pricefeeds
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {IDataProvider} from "src/interfaces/IDataProvider.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "src/interfaces/IERC20.sol";

contract ChainlinkAdapter is IDataProvider {
    // ==================
    //      STORAGE
    // ==================
    /**
     * SOL/USD AggregatorV3 price feed
     */
    AggregatorV3Interface SOL_USD_PRICEFEED;

    /**
     * ETH/USD AggregatorV3 price feed
     */
    AggregatorV3Interface ETH_USD_PRICEFEED;

    // ====================
    //      CONSTRUCTOR
    // ====================
    constructor(
        AggregatorV3Interface solUsdPricefeed,
        AggregatorV3Interface ethUsdPricefeed
    ) {
        SOL_USD_PRICEFEED = solUsdPricefeed;
        ETH_USD_PRICEFEED = ethUsdPricefeed;
    }

    /**
     * Quote SOL To ETH
     * @param solAmount - SOL Amount to quote (With decimals ofc)
     * @return ethAmount - Eth amount to get against that SOL
     */
    function quoteSOLToETH(
        uint256 solAmount
    ) external view returns (uint256 ethAmount) {
        uint256 solDecimals = 18;
        bool diviseSol = solAmount < 1 * 10 ** solDecimals;
        int256 solDivisorOrMultiplier = diviseSol
            ? int256(1 * 10 ** solDecimals) / int256(solAmount)
            : int256(solAmount) / int256(10 ** solDecimals);

        (, int256 solToUsdQuote, , , ) = SOL_USD_PRICEFEED.latestRoundData();

        uint256 usdRequiredForSol = diviseSol
            ? uint256(solToUsdQuote / solDivisorOrMultiplier)
            : uint256(solToUsdQuote * solDivisorOrMultiplier);

        (, int256 ethToUsdQuote, , , ) = ETH_USD_PRICEFEED.latestRoundData();

        ethAmount = 1 ether / (uint256(ethToUsdQuote) / usdRequiredForSol);
    }
}
