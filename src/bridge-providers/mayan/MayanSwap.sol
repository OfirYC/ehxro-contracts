/**
 * Bridge provider adapter for Mayanswap
 * Note it should be delegate called to by the execution diamond contract!
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "src/interfaces/IBridgeProvider.sol";
import {StorageManagerFacet} from "src/diamond/facets/core/StorageManager.sol";
import {RelayerFees, Criteria, Recepient} from "./Types.sol";
import "./StorageManager.sol";

contract MayanSwapAdapter is IBridgeProvider, MayanStorageManager {
    function bridgeHxroPayloadWithTokens(
        IERC20 token,
        uint256 amount,
        bytes memory hxroPayload
    ) external returns (BridgeResult memory bridgeResult) {
        RelayerFees memory relayerFees = _getRelayerFees();
    }

    // ==============
    //    INTERNAL
    // ==============
    function _getRelayerFees()
        internal
        view
        returns (RelayerFees memory relayerFees)
    {
        // Get swap fee
        uint256 requiredSolForSwap = solSwapFee();

        uint256 ethSwapFee = StorageManagerFacet(address(this))
            .getDataProvider()
            .quoteSOLToETH(requiredSolForSwap);

        uint256 refundFee = localRefundFee();

        relayerFees = RelayerFees({
            swapFee: uint64(ethSwapFee),
            redeemFee: 0,
            refundFee: uint64(refundFee)
        });
    }

    function _getRecepient(
        bytes32 solanaTokenAddr
    ) internal view returns (Recepient memory recepient) {
        bytes32 auctionProgram = mayanAuctionProgram();
        bytes32 ata = getMayanAssociatedTokenAccount(solanaTokenAddr);
        uint256 localChainId = solanaChainId();
        // recepient = Recepient({
        //     mayanAddr: mayanAuctionProgram(),

        // })
    }
}
