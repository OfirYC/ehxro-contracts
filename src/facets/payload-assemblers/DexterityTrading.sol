// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../../types/DexterityTrading.sol";
import "../../types/Main.sol";
import "../../storage/payload-assemblers/DexterityTrading.sol";

/**
 * @title Dexterity Trading Payload Facet
 * @author Ofir Smolinsky @OfirYC
 * @notice The facet responsible for building the eHXRO payloads for trading on Dexterity
 */

contract DexterityTradingPayloadFacet {
    // ================
    //     METHODS
    // ================
    /**
     * Build a deposit payload
     */
    function buildDepositPayload()
        external
        pure
        returns (bytes memory depositPayload)
    {}

    /**
     * Build a New Order payload
     * @param account - The account to build this payload ontop of
     * @param context - New Order Accounts Context
     * @param newOrderParams - New Order Params
     * @return newOrderPayload - The encoded HXRO payload
     */
    function buildNewOrderMessage(
        address account,
        NewOrderAccounts calldata context,
        NewOrderParams calldata newOrderParams
    ) external view returns (InboundPayload memory newOrderPayload) {
        DexterityTradingStorage
            storage dexterityStorage = DexterityTradingStorageLib.retreive();

        uint256 userNonce = dexterityStorage.nonces[account];

        bytes memory msgHash = bytes.concat(
            abi.encode(userNonce),
            abi.encode(context),
            abi.encode(newOrderParams)
        );

        newOrderPayload = InboundPayload(address(0), 0, msgHash);
    }

    /**
     * Build a Cancel Order payload
     */
    function buildCancelOrderPayload()
        external
        pure
        returns (bytes memory cancelOrderPayload)
    {}
}
