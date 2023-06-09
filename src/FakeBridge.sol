// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./diamond/interfaces/IBridgeProvider.sol";
import "./diamond/facets/core/StorageManager.sol";

/**
 * A very much real bridge provider
 */

contract VeryRealBridgeProvider is IBridgeProvider {
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

    function bridgeHxroPayload(
        bytes memory payload
    ) public returns (BridgeResult memory) {
        bytes32 solanaAddress = StorageManagerFacet(DIAMOND).getSolanaProgram();
        emit CrosschainPayloadTransfer(SOLANA_CHAIN_ID, solanaAddress, payload);

        return BridgeResult(SupportedBridges.VERY_REAL_BRIDGE, new bytes(32));
    }

    function bridgeHxroPayloadWithTokens(
        IERC20 token,
        uint256 amount,
        bytes memory payload
    ) public returns (BridgeResult memory) {
        bytes32 solanaAddress = StorageManagerFacet(DIAMOND).getSolanaProgram();

        emit CrosschainBridge(
            SOLANA_CHAIN_ID,
            solanaAddress,
            address(token),
            keccak256(abi.encode(address(token))),
            amount,
            payload
        );

        return BridgeResult(SupportedBridges.VERY_REAL_BRIDGE, new bytes(32));
    }
}
