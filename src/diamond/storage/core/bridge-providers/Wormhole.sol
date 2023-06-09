/**
 * Storage for Wormhole bridge provider
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct WormholeAdapterStorage {
    /**
     * Address of the wormhole core bridge
     */
    address coreBridge;
    /**
     * Address of the wormhole token bridge
     */
    address tokenBridge;
    /**
     * Solana chain ID
     */
    uint16 solanaChainId;
}

/**
 * The lib to use to retreive the storage
 */
library WormholeStorageLib {
    // ======================
    //       STORAGE
    // ======================
    // The namespace for the lib (the hash where its stored)
    bytes32 internal constant STORAGE_NAMESPACE =
        keccak256("diamond.hxro.storage.bridge_providers.wormhole");

    // Function to retreive our storage
    function retreive()
        internal
        pure
        returns (WormholeAdapterStorage storage s)
    {
        bytes32 position = STORAGE_NAMESPACE;
        assembly {
            s.slot := position
        }
    }
}
