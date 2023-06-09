// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "src/interfaces/IERC20.sol";
/**
 * Types for the eHXRO contracts
 */

struct InboundPayload {
    IERC20 token;
    uint256 amount;
    bytes messageHash;
}

enum SupportedBridges {
    WORMHOLE,
    VERY_REAL_BRIDGE
}

struct BridgeResult {
    SupportedBridges id;
    bytes res;
}

error NotSigOwner();

error UnsupportedToken();

error InvalidNonce();

error BridgeFailed(string revertReason);
