// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../../types/DexterityTrading.sol";

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
     */
    function buildNewOrderMessage()
        external
        pure
        returns (bytes memory newOrderPayload)
    {}

    /**
     * Build a Cancel Order payload
     */
    function buildCancelOrderPayload()
        external
        pure
        returns (bytes memory cancelOrderPayload)
    {}
}
