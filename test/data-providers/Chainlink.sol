/**
 * Tests for the Chainlink data provider
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "forge-std/Test.sol";
import {IDataProvider} from "src/interfaces/IDataProvider.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {Forks} from "../utils/Forks.t.sol";
import {ChainlinkAdapter} from "src/data-providers/chainlink/ChainlinkAdapter.sol";

contract ChainlinkDataProviderTest is Test {
    // ==============
    //     STATES
    // ==============
    IDataProvider CHAINLINK_DATA_PROVIDER;

    AggregatorV3Interface SOL_USD_PRICEFEED;

    AggregatorV3Interface ETH_USD_PRICEFEED;

    // ==============
    //     SETUP
    // ==============
    function setUp() external {
        uint256 networkID = new Forks().ARBITRUM();
        vm.selectFork(networkID);

        SOL_USD_PRICEFEED = AggregatorV3Interface(
            0x24ceA4b8ce57cdA5058b924B9B9987992450590c
        );

        ETH_USD_PRICEFEED = AggregatorV3Interface(
            0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        );

        CHAINLINK_DATA_PROVIDER = new ChainlinkAdapter(
            SOL_USD_PRICEFEED,
            ETH_USD_PRICEFEED
        );
    }

    // ==============
    //     TESTS
    // ==============
    function testSolanaQuote(uint64 solAmount) external {
        // Sol amount wont ever be mind boggingly huge

        (, int256 singleSolQuote, , , ) = SOL_USD_PRICEFEED.latestRoundData();

        uint256 supposedUsdAmount = (solAmount * uint256(singleSolQuote)) /
            10 ** 18;

        uint256 resEthAmount = CHAINLINK_DATA_PROVIDER.quoteSOLToETH(solAmount);

        (, int256 ethUsdQuote, , , ) = ETH_USD_PRICEFEED.latestRoundData();

        uint256 usdEthQuote = (resEthAmount * uint256(ethUsdQuote)) / 10 ** 18;

        assertApproxEqAbs(
            supposedUsdAmount,
            usdEthQuote,
            supposedUsdAmount / 100,
            "[ChainlinkDataProviderTest]: Quoted, but supposed USD amount != eth result quote"
        );
    }

    
}
