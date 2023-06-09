/**
 * Interface for a bridge provider
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../types/Main.sol";
import "./IERC20.sol";

interface IBridgeProvider {
    function bridgeHxroPayload(
        bytes memory hxroPayload
    ) external returns (BridgeResult memory);

    function bridgeHxroPayloadWithTokens(
        IERC20 token,
        uint256 amount,
        bytes memory hxroPayload
    ) external returns (BridgeResult memory);
}
