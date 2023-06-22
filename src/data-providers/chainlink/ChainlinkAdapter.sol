/**
 * Adapter for chainlink's pricefeeds
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "src/interfaces/IDataProvider.sol";
import "src/libs/Denominations.sol";

contract ChainlinkAdapter is IDataProvider {
    // ==================
    //      STORAGE
    // ==================

    /**
     * SOL/USD AggregatorV3 price feed
     */
    AggregatorV3Interface SOL_USD_PRICEFEED;
    /**
     *
     * @param tokenA - The token A to quote against
     * @param tokenB  - The token B to quote in
     * @param amountA  - The amount of token A to quote
     * @return amountB - The amount of token B against amountA
     */
    function quote(
        address tokenA,
        address tokenB,
        uint256 amountA
    ) external view returns (uint256 amountB) {}
}
