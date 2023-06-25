// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
struct RelayerFees {
    uint64 swapFee;
    uint64 redeemFee;
    uint64 refundFee;
}

struct Criteria {
    uint256 transferDeadline;
    uint64 swapDeadline;
    uint64 amountOutMin;
    bool unwrap;
    uint32 nonce;
}

struct Recepient {
    bytes32 mayanAddr;
    uint16 mayanChainId;
    bytes32 auctionAddr;
    bytes32 destAddr;
    uint16 destChainId;
}
