// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * A very much real bridge provider
 */

contract VeryRealBridgeProvider {
    // We want this to emit on a swap to consider first milestone a success
    event CrosschainSwap(
        uint64 chainId,
        address srcToken,
        address destToken,
        uint256 amtIn,
        bytes payload
    );

    function swap(
        uint64 chainId,
        address srcToken,
        address destToken,
        uint256 amtIn,
        bytes memory payload
    ) external {
        emit CrosschainSwap(chainId, srcToken, destToken, amtIn, payload);
    }
}
