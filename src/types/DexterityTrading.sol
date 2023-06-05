// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// =================
//      ENUMS
// =================

// The order's side (Bid or Ask)
enum Side {
    BID,
    ASK
}

// The order type (supported types include Limit, FOK, IOC and PostOnly)
enum OrderType {
    LIMIT,
    IMMEDIATE_OR_CANCEL,
    FILL_OR_KILL,
    POST_ONLY
}

// Configures what happens when this order is at least partially matched against an order belonging to the same user account
enum SelfTradeBehavior {
    // The orders are matched together
    DECREMENT_TAKE,
    // The order on the provide side is cancelled. Matching for the current order continues and essentially bypasses
    // the self-provided order.
    CANCEL_PROVIDE,
    // The entire transaction fails and the program returns an error.
    ABORT_TRANSACTION
}

// =================
//     STRUCTS
// =================

// The max quantity of base token to match and post
struct Fractional {
    uint256 m;
    uint256 exp;
}

// Params for a new order
struct NewOrderParams {
    Side side;
    Fractional max_base_qty;
    OrderType order_type;
    SelfTradeBehavior self_trade_behavior;
    uint256 match_limit;
    Fractional limit_price;
}
