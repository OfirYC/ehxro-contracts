/**
 * Storage specific to the execution facet
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct BridgeProvider {
    /**
     * Selector of the token + payload bridge function of this provider
     */
    bytes4 transferTokensAndPayloadSel;
    /**
     * Selector of the *only* payload bridge function of this provider
     */
    bytes4 transferPayloadSel;
}

struct CoreStorage {
    /**
     * Address of the solana eHXRO program
     */
    bytes32 solanaProgram;
    /**
     * All supported tokens
     */
    address[] allSupportedTokens;
    /**
     * Mapping local supported token addresses => Corresponding supporting bridge's adapter func selector
     */
    mapping(address => BridgeProvider) tokenBridgeProviders;
}

/**
 * The lib to use to retreive the storage
 */
library CoreStorageLib {
    // ======================
    //       STORAGE
    // ======================
    // The namespace for the lib (the hash where its stored)
    bytes32 internal constant STORAGE_NAMESPACE =
        keccak256("diamond.hxro.storage.core.execution");

    // Function to retreive our storage
    function retreive() internal pure returns (CoreStorage storage s) {
        bytes32 position = STORAGE_NAMESPACE;
        assembly {
            s.slot := position
        }
    }
}
