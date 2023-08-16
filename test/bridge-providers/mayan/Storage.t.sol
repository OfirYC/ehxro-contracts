// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "src/diamond/facets/core/StorageManager.sol";
import {MayanSwapAdapter} from "src/bridge-providers/mayan/MayanSwap.sol";
import {MayanStorageManagerFacet} from "src/diamond/facets/bridge-providers/mayan/StorageManager.sol";
import "test/diamond/Deployment.t.sol";
import {ChainlinkAdapter} from "src/data-providers/chainlink/ChainlinkAdapter.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MayanTestContract is DiamondTest {
    // ==========
    //   STORAGE
    // ==========
    IERC20 USDC = IERC20(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);

    bytes32 SOL_USDC =
        0xc6fa7af3bedbad3a3d65f36aabc97431b1bbe4c2d2f6e0e47ca60203452f5d61;

    bytes32 USDC_ATA =
        0xbf0281fb2d17811bf365954917f286fcc61df41a2a1bb0b22a2dbc945d94dbef;

    ITokenBridge mayanSwapAdapter;

    MayanStorageManagerFacet mayanStorageManager;

    StorageManagerFacet storageMangerFacet;

    uint16 SOLANA_CHAIN_ID = 1;

    bytes32 HXRO_SOLANA_PROGRAM =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 MAX_PRIV_KEY =
        115792089237316195423570985008687907852837564279074904382605163141518161494337;

    address mayanBridgeContract = 0xEFF34DdD6713aF74bE9ec9cD8350154cee9935a9;

    bytes32 mayanAuctionProgram =
        0xeb5ba14857795c3b8d83484fa47b19908ff619ae0673a7c7cd4f2c59da65b29e;

    address MAX_PRECOMPILE_ADDRESS = address(10);

    // 0.025 SOL
    uint256 solSwapFee = 25 * 10 ** 15;

    uint256 refundFee = 400000;

    // ==========
    //   SETUP
    // ==========
    function setUp() public virtual override {
        super.setUp();

        // Base setup
        mayanSwapAdapter = new MayanSwapAdapter();

        mayanStorageManager = MayanStorageManagerFacet(address(diamond));

        storageMangerFacet = StorageManagerFacet(address(diamond));

        ChainlinkAdapter dataProvider = new ChainlinkAdapter(
            AggregatorV3Interface(0x24ceA4b8ce57cdA5058b924B9B9987992450590c),
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612)
        );

        StorageManagerFacet(address(diamond)).setDataProvider(dataProvider);

        dataProvider.setTokenPriceFeed(
            address(USDC),
            AggregatorV3Interface(0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3)
        );

        // Classifies both in core storage and mayan storage
        mayanStorageManager.addMayanToken(
            address(USDC),
            SOL_USDC,
            mayanSwapAdapter,
            USDC_ATA
        );

        // address(0) == Used by non-token bridge (plain payliad)
        storageMangerFacet.setHxroSolanaProgram(HXRO_SOLANA_PROGRAM);

        mayanStorageManager.setSolanaChainId(SOLANA_CHAIN_ID);

        mayanStorageManager.setMayanBridgeContract(mayanBridgeContract);

        mayanStorageManager.setMayanAuctionProgram(mayanAuctionProgram);

        mayanStorageManager.setSolSwapFee(solSwapFee);

        mayanStorageManager.setLocalRefundFee(refundFee);
    }
}
