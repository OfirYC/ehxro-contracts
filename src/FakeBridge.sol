// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./interfaces/IBridgeProvider.sol";
import {StorageManagerFacet} from "./diamond/facets/core/StorageManager.sol";
import "forge-std/console.sol";

/**
 * A very much real bridge provider
 */

contract VeryRealBridgeProvider is ITokenBridge, IPayloadBridge {
    address DIAMOND;
    uint256 SOLANA_CHAIN_ID = 501484;

    constructor(address diamond) {
        DIAMOND = diamond;
    }

    // We want this to emit on a swap to consider first milestone a success
    event CrosschainBridge(
        uint256 indexed toChainId,
        bytes32 indexed destAddress,
        address indexed srcToken,
        bytes32 destToken,
        uint256 amtIn,
        bytes payload
    );

    event CrosschainPayloadTransfer(
        uint256 indexed toChainid,
        bytes32 indexed destAddress,
        bytes indexed payload
    );

    function bridgeHXROPayload(
        bytes calldata payload,
        address msgSender
    ) public returns (BridgeResult memory) {
        bytes32 solanaAddress = StorageManagerFacet(DIAMOND).getSolanaProgram();
        emit CrosschainPayloadTransfer(SOLANA_CHAIN_ID, solanaAddress, payload);

        return BridgeResult(Bridge.VERY_REAL_BRIDGE, new bytes(32));
    }

    function bridgeHxroPayloadWithTokens(
        bytes32 token,
        uint256 amount,
        address /** msgSender */,
        bytes calldata payload
    ) public returns (BridgeResult memory) {
        console.log("INside FUnc", DIAMOND);
        bytes32 solanaAddress = StorageManagerFacet(DIAMOND).getSolanaProgram();
        console.log("Got SOlana address:");
        console.logBytes32(solanaAddress);
        address srcToken = StorageManagerFacet(DIAMOND).getSourceToken(token);

        console.log("GOt Src Token", srcToken);

        emit CrosschainBridge(
            SOLANA_CHAIN_ID,
            solanaAddress,
            srcToken,
            token,
            amount,
            payload
        );

        return BridgeResult(Bridge.VERY_REAL_BRIDGE, new bytes(32));
    }
}
