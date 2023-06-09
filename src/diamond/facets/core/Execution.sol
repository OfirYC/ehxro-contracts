// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../../AccessControl.sol";
import "../../storage/core/Core.sol";
import "src/interfaces/IERC20.sol";
import "src/libs/SafeERC20.sol";
import "../../types/Main.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";

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
    using ECDSA for bytes32;

    // ===============
    //      CORE
    // ===============
    /**
     * Execute Hxro Payload AND transfer tokens along with it
     * @param inboundPayload - The inbound payload to execute
     * @param sig - The signature of the end user
     * @return bridgeRes - The result passed from the bridge, and the bridge identifier
     */
    function executeHxroPayloadWithTokens(
        InboundPayload memory inboundPayload,
        bytes calldata sig
    ) external returns (BridgeResult memory bridgeRes) {
        bytes memory messageHash = inboundPayload.messageHash;

        if (keccak256(messageHash).recover(sig) != msg.sender)
            revert NotSigOwner();

        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        uint256 nonce;
        assembly {
            let len := mload(messageHash)
            nonce := mload(add(messageHash, len))
        }

        if (nonce != coreStorage.nonces[msg.sender]) revert InvalidNonce();

        IBridgeProvider bridgeProvider = coreStorage.tokenBridgeProviders[
            inboundPayload.token
        ];

        if (address(bridgeProvider) == address(0)) revert UnsupportedToken();

        IERC20(inboundPayload.token).safeTransferFrom(
            msg.sender,
            address(this),
            inboundPayload.amount
        );

        bridgeRes = bridgeProvider.bridgeHxroPayloadWithTokens(
            inboundPayload.token,
            inboundPayload.amount,
            bytes.concat(inboundPayload.messageHash, sig) // HXRO payload convention always includes the sig
        );

        coreStorage.nonces[msg.sender]++;
    }

    /**
     * @notice
     * Execute Hxro Payload
     * @param inboundPayload - The inbound payload to execute
     * @param sig - The signature of the end user
     * @return bridgeRes - The result passed from the bridge, and the bridge identifier
     */
    function executeHxroPayload(
        InboundPayload memory inboundPayload,
        bytes calldata sig
    ) external returns (BridgeResult memory bridgeRes) {
        bytes memory messageHash = inboundPayload.messageHash;

        if (keccak256(messageHash).recover(sig) != msg.sender)
            revert NotSigOwner();

        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        uint256 nonce;
        assembly {
            let len := mload(messageHash)
            nonce := mload(add(mload(messageHash), len))
        }

        if (nonce != coreStorage.nonces[msg.sender]) revert InvalidNonce();

        IBridgeProvider bridgeProvider = coreStorage.tokenBridgeProviders[
            inboundPayload.token
        ];

        if (address(bridgeProvider) == address(0)) revert UnsupportedToken();

        bridgeRes = bridgeProvider.bridgeHxroPayload(
            bytes.concat(inboundPayload.messageHash, sig) // HXRO payload convention always includes the sig
        );

        coreStorage.nonces[msg.sender]++;
    }
}
