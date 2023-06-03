// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../../FakeBridge.sol";
import "../../AccessControl.sol";
import "../../storage/core/Core.sol";
import "../../interfaces/IERC20.sol";
import "../../libraries/SafeERC20.sol";
import "../../Types.sol";

/**
 * @title CoreFacet
 * @author Ofir Smolinsky @OfirYC
 * @notice The facet responsible for executing eHXRO payloads, interacting with users' funds and 3rd
 * party cross-chain providers. As well as enabling owners of the eHXRO contracts to whitelist new tokens
 * and bridges
 */

contract CoreFacet is AccessControlled {
    // ===============
    //      LIBS
    // ===============
    using SafeERC20 for IERC20;

    // ===============
    //      CORE
    // ===============
    /**
     * @notice
     * Execute Hxro Payload
     * @param encodedInboundPayload - The (encoded) inbound payload to execute
     */
    function executeHxroPayload(bytes calldata encodedInboundPayload, ) external {
        InboundPayload memory inboundPayload = abi.decode(
            encodedInboundPayload,
            (InboundPayload)
        );

        IERC20(inboundPayload.token).safeTransferFrom(msg.sender, address(this),)
    }

    // =======================
    //     CLASSIFICATIONS
    // =======================
    /**
     * Set a token's bridge selector
     * @param token - The token's address
     * @param bridgeSel - The function selector which the bridge adapter should call to bridge
     */
    function setTokenBridge(
        address token,
        bytes4 bridgeSel
    ) external onlyOwner {
        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        address[] memory supportedTokens = coreStorage.allSupportedTokens; // save gas by copying to memory once
        bool shouldPush = true;
        for (uint256 i; i < supportedTokens.length; i++)
            if (supportedTokens[i] == token) {
                shouldPush = false;
                break;
            }

        if (shouldPush) coreStorage.allSupportedTokens.push(token);

        coreStorage.tokenBridgeProviders[token] = bridgeSel;
    }
}
