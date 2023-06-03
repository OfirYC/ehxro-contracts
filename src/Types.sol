/**
 * Types for the eHXRO contracts
 */

struct InboundPayload {
    address token;
    uint256 amount;
    bytes messageHash;
}
