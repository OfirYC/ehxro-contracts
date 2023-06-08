// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../../FakeBridge.sol";
import "../../AccessControl.sol";
import "../../storage/core/Core.sol";
import "../../interfaces/IERC20.sol";
import "../../libraries/SafeERC20.sol";
import "../../types/Main.sol";

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
     * @param inboundPayload - The inbound payload to execute
     * @param sig - The signature of the end user
     * @return bridgeRes - The result passed from the bridge, and the bridge identifier
     */
    function executeHxroPayloadWithTokens(
        InboundPayload calldata inboundPayload,
        bytes calldata sig
    ) external returns (BridgeResult memory bridgeRes) {
        IERC20(inboundPayload.token).safeTransferFrom(
            msg.sender,
            address(this),
            inboundPayload.amount
        );

        BridgeProvider memory bridgeProvider = CoreStorageLib
            .retreive()
            .tokenBridgeProviders[inboundPayload.token];

        require(
            bridgeProvider.transferTokensAndPayloadSel != bytes4(0),
            "Token Unsupported"
        );

        // Bridge adapters sit on our diamond,
        // we delegatecall to the selector (delegatecall on ourselves to retain msg.sender context)
        (bool success, bytes memory res) = address(this).delegatecall(
            abi.encodeWithSelector(
                bridgeProvider.transferTokensAndPayloadSel,
                inboundPayload.token,
                inboundPayload.amount,
                bytes.concat(inboundPayload.messageHash, sig) // HXRO payload convention always includes the sig
            )
        );

        require(success, "HXRO: Failed To Bridge");

        bridgeRes = abi.decode(res, (BridgeResult));
    }

    // =======================
    //     CLASSIFICATIONS
    // =======================
    /**
     * Add a token's bridge selector
     * @param token - The token's address
     * @param bridgeProvider - The bridge provider config
     */
    function addTokenBridge(
        address token,
        BridgeProvider calldata bridgeProvider
    ) external onlyOwner {
        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        require(
            coreStorage.tokenBridgeProviders[token].transferPayloadSel ==
                bytes4(0),
            "Bridge Provider Already Added. Use updateTokenBridge"
        );

        coreStorage.tokenBridgeProviders[token] = bridgeProvider;
        coreStorage.allSupportedTokens.push(token);
    }

    /**
     * Update a token's bridge selector
     * @param token - The token's address
     * @param bridgeProvider - The bridge provider config
     */
    function updateTokenBridge(
        address token,
        BridgeProvider calldata bridgeProvider
    ) external onlyOwner {
        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        require(
            coreStorage.tokenBridgeProviders[token].transferPayloadSel !=
                bytes4(0),
            "Cannot Update Bridge Provider - Non Existant"
        );

        coreStorage.tokenBridgeProviders[token] = bridgeProvider;
    }
}
