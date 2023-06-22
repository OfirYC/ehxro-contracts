// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * Interface for a data provider adapters
 */
interface IDataProvider {
    function quote(
        address tokenA,
        address tokenB,
        uint256 amountA
    ) external view returns (uint256 amountB);

    function quoteSOLToETH(
        uint256 solAmount
    ) external view returns (uint256 ethAmount);
}
