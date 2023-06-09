/**
 * Read from & Write to core storage
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AccessControlled} from "../../AccessControl.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {IBridgeProvider} from "../../interfaces/IBridgeProvider.sol";
import "../../storage/core/Core.sol";
import "../../types/Main.sol";

contract StorageManagerFacet is AccessControlled {
    // ==============
    //     READ
    // ==============
    /**
     * Get all supported tokens
     * @return supportedTokens
     */
    function getSupportedTokens()
        external
        view
        returns (IERC20[] memory supportedTokens)
    {
        supportedTokens = CoreStorageLib.retreive().allSupportedTokens;
    }

    /**
     * Get a token's bridge provider
     */
    function getTokenBridgeProvider(
        IERC20 token
    ) external view returns (IBridgeProvider bridgeProvider) {
        bridgeProvider = CoreStorageLib.retreive().tokenBridgeProviders[token];
        require(
            address(bridgeProvider) != address(0),
            "Unsupported Bridge Provider"
        );
    }

    /**
     *  Get the solana program address (in bytes32)
     */
    function getSolanaProgram() external view returns (bytes32 solanaProgram) {
        solanaProgram = CoreStorageLib.retreive().solanaProgram;
    }

    /**
     * Get a user's nonce
     */
    function getUserNonce(address user) external view returns (uint256 nonce) {
        nonce = CoreStorageLib.retreive().nonces[user];
    }

    // ==============
    //     WRITE
    // ==============
    /**
     * Add a token's bridge selector
     * @param token - The token's address
     * @param bridgeProvider - The bridge provider
     */
    function addTokenBridge(
        IERC20 token,
        IBridgeProvider bridgeProvider
    ) external onlyOwner {
        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        require(
            address(coreStorage.tokenBridgeProviders[token]) == address(0),
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
        IERC20 token,
        IBridgeProvider bridgeProvider
    ) external onlyOwner {
        CoreStorage storage coreStorage = CoreStorageLib.retreive();

        require(
            address(coreStorage.tokenBridgeProviders[token]) != address(0),
            "Bridge Provider Already Added. Use updateTokenBridge"
        );

        coreStorage.tokenBridgeProviders[token] = bridgeProvider;
    }

    function setHxroSolanaProgram(bytes32 solanaProgram) external onlyOwner {
        CoreStorageLib.retreive().solanaProgram = solanaProgram;
    }
}
