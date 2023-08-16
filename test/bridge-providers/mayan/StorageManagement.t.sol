/**
 * Storage management test for Mayanswap
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "src/diamond/facets/core/StorageManager.sol";
import {MayanSwapAdapter} from "src/bridge-providers/mayan/MayanSwap.sol";
import {MayanStorageManagerFacet} from "src/diamond/facets/bridge-providers/mayan/StorageManager.sol";
import "test/diamond/Deployment.t.sol";
import "./Storage.t.sol";

contract MayanStorageManagementTest is MayanTestContract {
    // ==========
    //   SETUP
    // ==========
    function setUp() public virtual override {
        super.setUp();
    }

    // ==========
    //   TESTS
    // ==========

    function testAddingToken(address localToken) external {
        vm.assume(localToken > MAX_PRECOMPILE_ADDRESS);

        bytes32 solToken = keccak256(abi.encode(localToken));

        bytes32 ata = keccak256(abi.encode(solToken));

        vm.startPrank(address(50));

        // Not Owner
        vm.expectRevert();
        mayanStorageManager.addMayanToken(
            localToken,
            solToken,
            mayanSwapAdapter,
            ata
        );
        vm.stopPrank();

        mayanStorageManager.addMayanToken(
            localToken,
            solToken,
            mayanSwapAdapter,
            ata
        );

        bytes32 classifiedATA = mayanStorageManager
            .getMayanAssociatedTokenAccount(solToken);

        Token memory tokenData = StorageManagerFacet(address(diamond))
            .getTokenData(solToken);

        assertEq(
            classifiedATA,
            ata,
            "[MayanSwapStorageManagementTest]: Added Mayan Token, But ATA Mismatch"
        );

        assertEq(
            solToken,
            tokenData.solAddress,
            "[MayanSwapStorageManagementTest]: Added Mayan Token, But Core Storage Sol Token Address Mismatch"
        );

        assertEq(
            localToken,
            tokenData.localAddress,
            "[MayanSwapStorageManagementTest]: Added Mayan Token, But Core Storage Local Token Address Mismatch"
        );

        assertEq(
            address(mayanSwapAdapter),
            address(tokenData.bridgeProvider),
            "[MayanSwapStorageManagementTest]: Added Mayan Token, But Core Storage Bridge Provider Address Mismatch"
        );
    }

    function testGeneralStorageOps(address seed) external {
        bytes memory encodedSeed = abi.encode(seed);
        uint16 solChainId = uint16(uint256(keccak256(encodedSeed)));
        address mayanBridge = seed;
        bytes32 auctionProgram = keccak256(abi.encode(keccak256(encodedSeed)));
        uint256 solFee = uint256(keccak256(encodedSeed));
        uint256 refFee = uint256(keccak256(abi.encode(auctionProgram)));

        mayanStorageManager.setSolanaChainId(solChainId);

        mayanStorageManager.setMayanBridgeContract(mayanBridge);

        mayanStorageManager.setMayanAuctionProgram(auctionProgram);

        mayanStorageManager.setSolSwapFee(solFee);

        mayanStorageManager.setLocalRefundFee(refFee);

        assertEq(
            mayanStorageManager.solanaChainId(),
            solChainId,
            "[MayanSwapStorageManagementTest]: Added Sol Chain ID, but storage mismatches"
        );

        assertEq(
            address(mayanStorageManager.mayanswap()),
            mayanBridge,
            "[MayanSwapStorageManagementTest]: Added Mayan Bridge contract, but storage mismatches"
        );

        assertEq(
            mayanStorageManager.mayanAuctionProgram(),
            auctionProgram,
            "[MayanSwapStorageManagementTest]: Added Mayan Auction program, but storage mismatches"
        );

        assertEq(
            mayanStorageManager.solSwapFee(),
            solFee,
            "[MayanSwapStorageManagementTest]: Added SOL fee, but storage mismatches"
        );

        vm.txGasPrice(1);

        assertEq(
            mayanStorageManager.localRefundFee(),
            refFee,
            "[MayanSwapStorageManagementTest]: Added Local Refund fee, but storage mismatches"
        );
    }
}
