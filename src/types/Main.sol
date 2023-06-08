// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/**
 * Types for the eHXRO contracts
 */

struct InboundPayload {
    address token;
    uint256 amount;
    bytes messageHash;
}

enum SupportedBridges {
    WORMHOLE
}

struct BridgeResult {
    SupportedBridges id;
    bytes res;
}
